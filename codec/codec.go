package codec

import (
	"github.com/cosmos/cosmos-sdk/codec"
	app "github.com/cybercongress/cyberd/app"
)

// Codec is the application-wide Amino codec and is initialized upon package
// loading.
var Codec *codec.Codec

func init() {
	Codec = app.MakeCodec()
	app.SetPrefix()
	Codec.Seal()
}
