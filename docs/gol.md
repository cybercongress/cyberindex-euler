# Relevance

Tables:

- rewards_view

```json
{
    object: str, // CID from the top 1000
    rank: float, // rank of the current CID
    subject: str, // subject linked CID
    timestamp: date, // first tx date
    height: int, // first tx height
    cnt: int, // amount of links with that CID
    order_number: int, // subject order number for this CID
    share: float // subject share
}
```

- relevance_leaderboard

```json
{
    subject: str, // subject
    share: float // subject share
}
```

> Example. Get account cyberlinks with shares

```json
query relevance {
  rewards_view(where: {subject: {_eq: "cyber1wnpak7sfawsfv9c8vqe7naxfa4g99lv764drcl"}}) {
    object
    share
  }
}
```

Output:

```json
{
  "data": {
    "rewards_view": [
      {
        "object": "QmdTrXkTjZEWtnWCTkTmPv9GTWTWDv39UVDEorkU1SXEib",
        "share": 0.0005255378950966016
      },
      {
        "object": "QmXB4J5wrYeYHK8UtbG2JbZpkTuBDrb5Qj1vfi5vquWDiP",
        "share": 0.00044220588383696703
      },
      {
        "object": "QmSQ8XoaYmD7u8sYzmzMPFxqUTLB1Y1E52JnuBJ93W2RwE",
        "share": 0.00042150878642798146
      },
      {
        "object": "QmXoHnXVXK9Wyo9CB9kc3qjY5vmMytWKs6xR1WcUGNcTNS",
        "share": 0.00041577099847460165
      },
      {
        "object": "QmP566Q799VCRQVSvK1GJT32T7TCcxYknTQZf9sS9HBqDd",
        "share": 0.0004085474877899245
      },
      {
        "object": "QmPJPbfE2ZKTo7LQvoesxHa7FuvdzJQoBmG9ribg3GQz3R",
        "share": 0.0003436195549136868
      },
      {
        "object": "QmWqqJMeKPpDufLX56s1ECd54wm2LtjREyvp7XfpBtoCap",
        "share": 0.00030164662130978187
      }
    ]
  }
}
```

> Example. Get relevance leaderboard

```json
query relevance_leaderboard {
  relevance_leaderboard {
    subject
    share
  }
}
```

Output:

```json
{
  "data": {
    "relevance_leaderboard": [
      {
        "subject": "cyber1679yrs8dmska7wcsawgy2m25kwucm3z0nks9ze",
        "share": 0.540918269283645
      },
      {
        "subject": "cyber15zs0cjct43xs4z4sesxcrynar5mxm82ftu9vgv",
        "share": 0.17517861761871042
      },
      {
        "subject": "cyber1ymprf45c44rp9k0g2r84w2tjhsq7kalvplsnkk",
        "share": 0.12875410894179257
      },
      {
        "subject": "cyber18naxcfp2s397a2ucav2m53f003uylk3qxa6h5r",
        "share": 0.10103689877137827
      },
      {
        "subject": "cyber1hmkqhy8ygl6tnl5g8tc503rwrmmrkjcq4878e0",
        "share": 0.04707593762804102
      },
      {
        "subject": "cyber1en69twaxmv7xupy8lq7y539dpecx7yz8vh9u7k",
        "share": 0.0032917113012448304
      },
      {
        "subject": "cyber1wnpak7sfawsfv9c8vqe7naxfa4g99lv764drcl",
        "share": 0.0028588372278495447
      },
      {
        "subject": "cyber1stfw0z5nf2ncxxtrk7zndpf2dla3nh37ppm40e",
        "share": 0.00044914996403698135
      },
      {
        "subject": "cyber1zy553za8nenzukmv65240323jhuvxzym3evpec",
        "share": 0.00022457498201849068
      },
      {
        "subject": "cyber147rnn0rxqkythj4j9ccq0kytmh7f005rhhw240",
        "share": 0.00011228749100924534
      },
      {
        "subject": "cyber1dt9lwmuq8rkngm5gajxchqhpcnavgp7mfal7ac",
        "share": 0.0000996068163493331
      }
    ]
  }
}
```

Also, it is possible to get account relevance total share by the following query

```json
query account_share {
  relevance_leaderboard(where: {subject: {_eq: "cyber1hmkqhy8ygl6tnl5g8tc503rwrmmrkjcq4878e0"}}) {
    subject
    share
  }
}
```

Output:

```json
{
  "data": {
    "relevance_leaderboard": [
      {
        "subject": "cyber1hmkqhy8ygl6tnl5g8tc503rwrmmrkjcq4878e0",
        "share": 0.04707593762804102
      }
    ]
  }
}
```