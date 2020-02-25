package db

import (
	"database/sql"
	"encoding/base64"
	"encoding/json"
	"fmt"

	"github.com/cybercongress/cyberd/x/link"
	_ "github.com/lib/pq" // nolint
	"github.com/rs/zerolog/log"
	tmctypes "github.com/tendermint/tendermint/rpc/core/types"
	tmtypes "github.com/tendermint/tendermint/types"
	"github.com/tidwall/gjson"

	junocdc "github.com/cybercongress/cyberindex/codec"
	"github.com/cybercongress/cyberindex/config"

	sdk "github.com/cosmos/cosmos-sdk/types"
	"github.com/cosmos/cosmos-sdk/x/auth"
)

// Database defines a wrapper around a SQL database and implements functionality
// for data aggregation and exporting.
type Database struct {
	*sql.DB
}

// OpenDB opens a database connection with the given database connection info
// from config. It returns a database connection handle or an error if the
// connection fails.
func OpenDB(cfg config.Config) (*Database, error) {
	sslMode := "disable"
	if cfg.DB.SSLMode != "" {
		sslMode = cfg.DB.SSLMode
	}

	connStr := fmt.Sprintf(
		"host=%s port=%d dbname=%s user=%s sslmode=%s",
		cfg.DB.Host, cfg.DB.Port, cfg.DB.Name, cfg.DB.User, sslMode,
	)

	if cfg.DB.Password != "" {
		connStr += fmt.Sprintf(" password=%s", cfg.DB.Password)
	}

	db, err := sql.Open("postgres", connStr)
	if err != nil {
		return nil, err
	}

	return &Database{db}, nil
}

// LastBlockHeight returns the latest block stored.
func (db *Database) LastBlockHeight() (int64, error) {
	var height int64
	err := db.QueryRow("SELECT coalesce(MAX(height),0) AS height FROM block;").Scan(&height)
	return height, err
}

// HasBlock returns true if a block by height exists. An error should never be
// returned.
func (db *Database) HasBlock(height int64) (bool, error) {
	var res bool
	err := db.QueryRow(
		"SELECT EXISTS(SELECT 1 FROM block WHERE height = $1);",
		height,
	).Scan(&res)

	return res, err
}

// HasValidator returns true if a given validator by HEX address exists. An
// error should never be returned.
func (db *Database) HasValidator(addr string) (bool, error) {
	var res bool
	err := db.QueryRow(
		"SELECT EXISTS(SELECT 1 FROM validator WHERE address = $1);",
		addr,
	).Scan(&res)

	return res, err
}

// SetValidator stores a validator if it does not already exist. An error is
// returned if the operation fails.
func (db *Database) SetValidator(addr, pk string) error {
	_, err := db.Exec(
		"INSERT INTO validator (address, consensus_pubkey) VALUES ($1, $2) ON CONFLICT DO NOTHING RETURNING id;",
		addr, pk,
	)

	return err
}

// SetPreCommit stores a validator's pre-commit and returns the resulting record
// ID. An error is returned if the operation fails.
func (db *Database) SetPreCommit(pc tmtypes.CommitSig, vp, pp int64) (uint64, error) {
	var id uint64

	sqlStatement := `
	INSERT INTO pre_commit (validator_address, timestamp, voting_power, proposer_priority)
	VALUES ($1, $2, $3, $4)
	RETURNING id;
	`

	err := db.QueryRow(
		sqlStatement,
		pc.ValidatorAddress.String(), pc.Timestamp, vp, pp,
	).Scan(&id)

	return id, err
}

// SetBlock stores a block and returns the resulting record ID. An error is
// returned if the operation fails.
func (db *Database) SetBlock(b *tmctypes.ResultBlock, tg, pc uint64) (uint64, error) {
	var id uint64

	sqlStatement := `
	INSERT INTO block (height, hash, total_gas, proposer_address, pre_commits, timestamp)
	VALUES ($1, $2, $3, $4, $5, $6)
	RETURNING id;
	`

	err := db.QueryRow(
		sqlStatement,
		b.Block.Height, b.Block.Hash().String(),
		tg, b.Block.ProposerAddress.String(), pc, b.Block.Time,
	).Scan(&id)

	return id, err
}

type signature struct {
	Address   string `json:"address,omitempty"`
	Pubkey    string `json:"pubkey,omitempty"`
	Signature string `json:"signature,omitempty"`
}

// SetTx stores a transaction and returns the resulting record ID. An error is
// returned if the operation fails.
func (db *Database) SetTx(tx sdk.TxResponse) (uint64, error) {
	var id uint64

	sqlStatement := `
	INSERT INTO transaction (timestamp, gas_wanted, gas_used, height, txhash, subject, events, messages, fee, signatures, memo, code, rawlog)
	VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11, $12, $13)
	RETURNING id;
	`

	stdTx, ok := tx.Tx.(auth.StdTx)
	if !ok {
		return 0, fmt.Errorf("unsupported tx type: %T", tx.Tx)
	}

	eventsBz, err := junocdc.Codec.MarshalJSON(tx.Logs)
	if err != nil {
		return 0, fmt.Errorf("failed to JSON encode tx events: %s", err)
	}

	msgsBz, err := junocdc.Codec.MarshalJSON(stdTx.GetMsgs())
	if err != nil {
		return 0, fmt.Errorf("failed to JSON encode tx messages: %s", err)
	}

	feeBz, err := junocdc.Codec.MarshalJSON(stdTx.Fee)
	if err != nil {
		return 0, fmt.Errorf("failed to JSON encode tx fee: %s", err)
	}

	// convert Tendermint signatures into a more human-readable format
	sigs := make([]signature, len(stdTx.GetSignatures()), len(stdTx.GetSignatures()))
	for i, pub := range stdTx.GetPubKeys() {
		accPubKey, err := sdk.Bech32ifyPubKey(sdk.Bech32PubKeyTypeAccPub,pub)
		if err != nil {
			return 0, fmt.Errorf("failed to convert validator public key %s: %s\n", pub, err)
		}

		accAddress, err := sdk.AccAddressFromHex(stdTx.GetSigners()[i].String())
		if err != nil {
			return 0, fmt.Errorf("failed to convert account address %s: %s\n", stdTx.GetSigners()[i].String(), err)
		}

		sigs[i] = signature{
			Address:   accAddress.String(),
			Signature: base64.StdEncoding.EncodeToString(stdTx.GetSignatures()[i]),
			Pubkey:    accPubKey,
		}
	}

	sigsBz, err := junocdc.Codec.MarshalJSON(sigs)
	if err != nil {
		return 0, fmt.Errorf("failed to JSON encode tx signatures: %s", err)
	}
	err = db.QueryRow(
		sqlStatement,
		tx.Timestamp, tx.GasWanted, tx.GasUsed, tx.Height, tx.TxHash, sigs[0].Address, string(eventsBz),
		string(msgsBz), string(feeBz), string(sigsBz), stdTx.GetMemo(), int64(tx.Code), tx.RawLog,
	).Scan(&id)

	if (tx.Code == 0) {
		if err := db.ExportParsedTx(tx, msgsBz); err != nil {
			return 0, err
		}
	}

	return id, err
}

type LinkMsg struct {
	Type  string
	Value link.Msg
}

func (db *Database) ExportParsedTx(tx sdk.TxResponse, msgsBz []byte) error {

	// TODO bad design for this, rewrite all using tx decoder and seperate logic

	var CyberMsgs []LinkMsg;
	json.Unmarshal([]byte(msgsBz), &CyberMsgs)

	stdTx, _ := tx.Tx.(auth.StdTx)

	strMsgs := string(msgsBz)
	parsedStrMsgs := gjson.Parse(strMsgs)
	var rawMsgs []string;

	parsedStrMsgs.ForEach(func(key, value gjson.Result) bool {
		rawMsgs = append(rawMsgs, gjson.Get(value.String(), "value").String())
		return true
	})

	for i, msg := range CyberMsgs {
		if msg.Type == "cyberd/Link" {
			for _, link := range msg.Value.Links {
				_, errMsg := db.SetCyberlink(link, msg.Value.Address, tx); if errMsg != nil {
					log.Error().Err(errMsg).Str("hash", tx.TxHash).Msg("failed to write cyberlink")
				}
			}
		} else {
			//sig := stdTx.GetSignatures()[0] // TODO refactor this
			accAddress, _ := sdk.AccAddressFromHex(stdTx.GetSigners()[i].String())
			_, errMsg := db.SetMessage(msg.Type, rawMsgs[i], accAddress.String(), tx); if errMsg != nil {
				log.Error().Err(errMsg).Str("hash", tx.TxHash).Msg("failed to write message")
			}
		}
	}

	return nil
}

func (db *Database) SetCyberlink(link link.Link, address sdk.AccAddress, tx sdk.TxResponse) (uint64, error) {
	var id uint64

	sqlStatement := `
	INSERT INTO cyberlink (object_from, object_to, subject, timestamp, height, txhash)
	VALUES ($1, $2, $3, $4, $5, $6)
	RETURNING id;
	`

	err := db.QueryRow(
		sqlStatement,
		link.From, link.To, address.String(), tx.Timestamp, tx.Height, tx.TxHash,
	).Scan(&id)

	// TODO later upgrade tx/msgs indexing with new JUNO release
	_, errMsg := db.SetObject(link.To, address, tx); if errMsg != nil {
		log.Error().Err(errMsg).Str("hash", tx.TxHash).Msg("failed to write object")
	}
	_, errMsg = db.SetObject(link.From, address, tx); if errMsg != nil {
		log.Error().Err(errMsg).Str("hash", tx.TxHash).Msg("failed to write object")
	}

	return id, err
}

func (db *Database) SetMessage(types string, value string, address string, tx sdk.TxResponse) (uint64, error) {
	var id uint64

	sqlStatement := `
	INSERT INTO message (subject, type, value, timestamp, height, txhash)
	VALUES ($1, $2, $3, $4, $5, $6)
	RETURNING id;
	`

	err := db.QueryRow(
		sqlStatement,
		address, types, value, tx.Timestamp, tx.Height, tx.TxHash,
	).Scan(&id)

	return id, err
}

func (db *Database) SetObject(object link.Cid, address sdk.AccAddress, tx sdk.TxResponse) (uint64, error) {
	var id uint64

	sqlStatement := `
	INSERT INTO object (object, subject, timestamp, height, txhash)
	VALUES ($1, $2, $3, $4, $5)
	RETURNING id;
	`

	err := db.QueryRow(
		sqlStatement,
		object, address.String(), tx.Timestamp, tx.Height, tx.TxHash,
	).Scan(&id)

	return id, err
}

// ExportBlock accepts a finalized block and a corresponding set of transactions
// and persists them to the database along with attributable metadata. An error
// is returned if the write fails.
func (db *Database) ExportBlock(b *tmctypes.ResultBlock, txs []sdk.TxResponse, vals *tmctypes.ResultValidators) error {
	totalGas := sumGasTxs(txs)
	preCommits := uint64(len(b.Block.LastCommit.Signatures))

	// Set the block's proposer if it does not already exist. This may occur if
	// the proposer has never signed before.
	proposerAddr := b.Block.ProposerAddress.String()

	val := findValidatorByAddr(proposerAddr, vals)
	if val == nil {
		err := fmt.Errorf("failed to find validator by address %s for block %d", proposerAddr, b.Block.Height)
		log.Error().Str("validator", proposerAddr).Int64("height", b.Block.Height).Msg("failed to find validator by address")
		return err
	}

	if err := db.ExportValidator(val); err != nil {
		return err
	}

	if _, err := db.SetBlock(b, totalGas, preCommits); err != nil {
		log.Error().Err(err).Int64("height", b.Block.Height).Msg("failed to persist block")
		return err
	}

	for _, tx := range txs {
		if _, err := db.SetTx(tx); err != nil {
			log.Error().Err(err).Str("hash", tx.TxHash).Msg("failed to persist transaction")
			return err
		}
	}

	return nil
}

// ExportValidator persists a Tendermint validator with an address and a
// consensus public key. An error is returned if the public key cannot be Bech32
// encoded or if the DB write fails.
func (db *Database) ExportValidator(val *tmtypes.Validator) error {
	valAddr := val.Address.String()

	consPubKey, err := sdk.Bech32ifyPubKey(sdk.Bech32PubKeyTypeConsPub,val.PubKey) // nolint: typecheck
	if err != nil {
		log.Error().Err(err).Str("validator", valAddr).Msg("failed to convert validator public key")
		return err
	}

	if err := db.SetValidator(valAddr, consPubKey); err != nil {
		log.Error().Err(err).Str("validator", valAddr).Msg("failed to persist validator")
		return err
	}

	return nil
}

// ExportPreCommits accepts a block commitment and a coressponding set of
// validators for the commitment and persists them to the database. An error is
// returned if any write fails or if there is any missing aggregated data.
func (db *Database) ExportPreCommits(commit *tmtypes.Commit, vals *tmctypes.ResultValidators) error {
	// persist all validators and pre-commits
	for _, pc := range commit.Signatures {
		valAddr := pc.ValidatorAddress.String()

		val := findValidatorByAddr(valAddr, vals)
		if val == nil {
			err := fmt.Errorf("failed to find validator by address %s for block %d", valAddr, commit.Height)
			log.Error().Msg(err.Error())
			return err
		}

		if err := db.ExportValidator(val); err != nil {
			return err
		}

		if _, err := db.SetPreCommit(pc, val.VotingPower, val.ProposerPriority); err != nil {
			log.Error().Err(err).Str("validator", valAddr).Msg("failed to persist validator pre-commit")
			return err
		}
	}

	return nil
}
