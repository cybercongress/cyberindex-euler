# Analytics graphQL queries for cyber

## Cohorts

There is a separate API microservice for cohorts data. 

The return of any query to this microservice is json like:

```json
{
  "x" : ["string"],
  "y" : ["date"],
  "z" : [["data"]]
}
```

This data structure-oriented for a [heatmap](https://plotly.com/javascript/heatmaps/) of poltly js library. 

Where `x` is months order from 0 till current, + "Messed" and "Total".
`y` is month order from April till current in date format. In other words, this is the month of registration.
`z` is data for filling cohort as a double array mapped with `x` and `y`.

There are three parameters you can use as filters to get data from that microservice:

- `register_source`
- `register_type`
- `action_type`

***register_source***. Source of account registration. Will return only accounts with the current source of registration as a parameter.
Parametres: 
- `ethereum`
- `cosmos`
- `urbit`
- `euler4`
- `new`
If `register_source` is not specified API will return all accounts.

***register_type***. Type of account registration. Will return only accounts with the current type of registration as a parameter.
Parametres: 
- `stake`
- `transfer`
- `cyberlink`
- `euler4`
- `withdraw`
If `register_type` is not specified API will return all accounts independent of registration type.

***register_type***. Type of the first account action. Will return only accounts with the current type of the first action as a parameter.
Parametres: 
- `stake`
- `transfer`
- `cyberlink`
- `euler4`
- `withdraw`
If register_type is not specified API will return all accounts independent of the first action type.

Concatenating queries is available with `&` and with order save like `register_source`, `register_type` and `action_type`. 

> Example. Get all accounts from `euler4` gift with type of registration `transfer`.

```bash
/register_source=euler4&register_type=transfer
```

If you need cohort data without filters query:

```bash
/cohort_main
```

## Accounts by activity table

Tables: 

- accs_by_act

```
{
    subject: str, // account address
    first_delegation: date, // date of the first delegation transaction
    first_send: date, // date of the first send transaction (include multisend)
    fisrt_link: date, // date of the first cyberlink transaction
    first_follow: date, // date of the first follow transaction (link tx from CID("follow"))
    first_avatar: date, // date of the first avatar transaction (link tx from CID("avatar"))
    follows: int, // the amount of follows by subject
    cyberlinks: int, // the amount of cyberlinks by subject
    tweets: int, // the amount of tweets by subject (link txs from CID("tweet))
    first_5_folls: date, // date of 5 follow txs achieving
    first_25_folls, // date of 5 follow txs achieving
    first_10_links, // date of 10 cyberlink txs achieving
    first_100_links, // date of 100 cyberlink txs achieving
}
```

Get account activity:

```
query get_account_activity {
  accs_by_act(where: {subject: {_eq: "cyber1hmkqhy8ygl6tnl5g8tc503rwrmmrkjcq4878e0"}}) {
    cyberlinks
    first_100_links
    first_10_links
    first_25_folls
    first_5_folls
    first_avatar
    first_delegation
    first_follow
    first_link
    first_send
    follows
    subject
    tweets
  }
}
```

Output:

```json
{
  "data": {
    "accs_by_act": [
      {
        "cyberlinks": 11748,
        "first_100_links": "2020-04-20",
        "first_10_links": "2020-04-08",
        "first_25_folls": null,
        "first_5_folls": null,
        "first_avatar": "2020-07-17",
        "first_delegation": "2020-04-21",
        "first_follow": "2020-07-16",
        "first_link": "2020-04-08",
        "first_send": "2020-04-08",
        "follows": 3,
        "subject": "cyber1hmkqhy8ygl6tnl5g8tc503rwrmmrkjcq4878e0",
        "tweets": 4
      }
    ]
  }
}
```

Get accounts by activity type:

> Example. Get accounts with avatar

```
query get_accounts_with_avatar {
  accs_by_act(where: {first_avatar: {_is_null: false}}) {
    subject
  }
}
```

Output:

```json
{
  "data": {
    "accs_by_act": [
      {
        "subject": "cyber12u6qgyrdsy4xmw04vfkkkh9a9tqzw66gsay86k"
      },
      {
        "subject": "cyber158mysantvvk7x65tfhhuu8q2va4ls34rsdydf6"
      },
      {
        "subject": "cyber1a4mzr2y2g0cc9f0uhyeh3ftmsfxzqwxffcckf9"
      },
      {
        "subject": "cyber1cg79pj70mgl8xlum0rw5yy6enk9jszsrx5al8w"
      },
      {
        "subject": "cyber1clalfxmsrqdgnqq5uxlx0mc983pyp3wq37v5x9"
      },
      {
        "subject": "cyber1gw5kdey7fs9wdh05w66s0h4s24tjdvtcp5fhky"
      },
      {
        "subject": "cyber1hmkqhy8ygl6tnl5g8tc503rwrmmrkjcq4878e0"
      },
      {
        "subject": "cyber1l5x6kerswths5xl0d6672y9yyn9mg2vwru30ja"
      },
      {
        "subject": "cyber1latzme6xf6s8tsrymuu6laf2ks2humqvdq39v8"
      },
      {
        "subject": "cyber1mn8ev805fde2xswght0snwfayfj9tn54fnew44"
      },
      {
        "subject": "cyber1p0r7uxstcw8ehrwuj4kn8qzzs0yypsjwzs7wzf"
      },
      {
        "subject": "cyber1pjvkddp4fmx8ym5j7s7su8kn3zuqj255f2369q"
      },
      {
        "subject": "cyber1qe4sguqg8ztlyy7psf7lzwr4ahph9j36jvyyul"
      },
      {
        "subject": "cyber1qn8sr2hzmktlecusdtxj9hwj0upnm0jf0arg27"
      },
      {
        "subject": "cyber1s2a7rckcky6jmhncxwy0xtwf2ymg87pujzp64l"
      }
    ]
  }
}
```

## Accounts by source of registration tables

Next two sections for chart representation. Checked via https://www.smashingmagazine.com/2019/03/realtime-charts-graphql-postgres/

Tables:

- cosmos_total
- ethereum_total
- euler4_total
- new_total
- unique_total
- urbit total

for all tables:

```
{
    date: date, 
    account: int, // register unique accounts per day
    total: int, // register unique accounts per day accumulated
}
```

*account field is separate in separate tables. Browse hasura UI for details.

> Example. Get new accounts from Cosmos gift addresses pool for the last week:

```
query get_cosmos_per_day {
  cosmos_total(where: {date: {_gte: "2020-11-03"}}) {
    cosmos
    date
  }
}
```

Output:

```json
{
  "data": {
    "cosmos_total": [
      {
        "cosmos": 0,
        "date": "2020-11-03"
      },
      {
        "cosmos": 0,
        "date": "2020-11-04"
      },
      {
        "cosmos": 0,
        "date": "2020-11-05"
      },
      {
        "cosmos": 0,
        "date": "2020-11-06"
      },
      {
        "cosmos": 0,
        "date": "2020-11-07"
      },
      {
        "cosmos": 0,
        "date": "2020-11-08"
      },
      {
        "cosmos": 0,
        "date": "2020-11-09"
      },
      {
        "cosmos": 0,
        "date": "2020-11-10"
      },
      {
        "cosmos": 0,
        "date": "2020-11-11"
      }
    ]
  }
}
```

> Example. Get new accounts from Cosmos gift addresses pool for the last week accumulated:

```
query get_cosmos_per_day_accumulated {
  cosmos_total(where: {date: {_gte: "2020-11-03"}}) {
    total
    date
  }
}
```

Output:

```
{
  "data": {
    "cosmos_total": [
      {
        "total": 8,
        "date": "2020-11-03"
      },
      {
        "total": 8,
        "date": "2020-11-04"
      },
      {
        "total": 8,
        "date": "2020-11-05"
      },
      {
        "total": 8,
        "date": "2020-11-06"
      },
      {
        "total": 8,
        "date": "2020-11-07"
      },
      {
        "total": 8,
        "date": "2020-11-08"
      },
      {
        "total": 8,
        "date": "2020-11-09"
      },
      {
        "total": 8,
        "date": "2020-11-10"
      },
      {
        "total": 8,
        "date": "2020-11-11"
      }
    ]
  }
}
```

## General users activity

Tables:

- tweets_total
- cyberlinks_total

```
{
    date: date, 
    tweets/links: int, // tweets/links per day
    total: int, // tweets/links per day accumulated
}
```

> Example. Get tweets per day for the last two weeks

```
query tweets_per_day {
  tweets_total(where: {date: {_gte: "2020-10-29"}}) {
    date
    tweets
  }
}
```

Output:

```json
{
  "data": {
    "tweets_total": [
      {
        "date": "2020-10-29",
        "tweets": 5
      },
      {
        "date": "2020-10-30",
        "tweets": 0
      },
      {
        "date": "2020-10-31",
        "tweets": 1
      },
      {
        "date": "2020-11-01",
        "tweets": 0
      },
      {
        "date": "2020-11-02",
        "tweets": 8
      },
      {
        "date": "2020-11-03",
        "tweets": 0
      },
      {
        "date": "2020-11-04",
        "tweets": 0
      },
      {
        "date": "2020-11-05",
        "tweets": 0
      },
      {
        "date": "2020-11-06",
        "tweets": 0
      },
      {
        "date": "2020-11-07",
        "tweets": 0
      },
      {
        "date": "2020-11-08",
        "tweets": 0
      },
      {
        "date": "2020-11-09",
        "tweets": 0
      },
      {
        "date": "2020-11-10",
        "tweets": 0
      },
      {
        "date": "2020-11-11",
        "tweets": 0
      }
    ]
  }
}
```

> Example. Get links per day for the last two weeks accumulated

```
query cyberlinks_per_day_acc {
  cyberlinks_total(where: {date: {_gte: "2020-10-29"}}) {
    date
    total
  }
}
```

Output:

```json
{
  "data": {
    "cyberlinks_total": [
      {
        "date": "2020-10-29",
        "total": 874226
      },
      {
        "date": "2020-10-30",
        "total": 875056
      },
      {
        "date": "2020-10-31",
        "total": 875384
      },
      {
        "date": "2020-11-01",
        "total": 875671
      },
      {
        "date": "2020-11-02",
        "total": 876178
      },
      {
        "date": "2020-11-03",
        "total": 876753
      },
      {
        "date": "2020-11-04",
        "total": 879515
      },
      {
        "date": "2020-11-05",
        "total": 883510
      },
      {
        "date": "2020-11-06",
        "total": 885194
      },
      {
        "date": "2020-11-07",
        "total": 886381
      },
      {
        "date": "2020-11-08",
        "total": 886447
      },
      {
        "date": "2020-11-09",
        "total": 886447
      },
      {
        "date": "2020-11-10",
        "total": 886447
      },
      {
        "date": "2020-11-11",
        "total": 886447
      }
    ]
  }
}
```