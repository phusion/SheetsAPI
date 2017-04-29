Simple Sheets API
============================

This gem contains a simple API to insert data into google sheets.

Authentication
==============

This gem needs to authenticate as a Google Service Account to access files.
Follow these steps to download the credentials you need:

1. Go to https://console.developers.google.com/apis/dashboard
2. Create a new Project (if you have to)
2. Enable the Google Sheets API
3. Go to 'Credentials'
4. Create Credentials for a 'Service account key'
6. Under 'Service account' select your Project. Key type JSON.
7. Save the downloaded file as 'GoogleAPICredentials.json' in the root of your project

To give the API access to a sheet in Google Sheets, you need to specifically share that document with the Service Account.
In the GoogleAPICredentials.json file you will find a `client_email` field. Share a document with that email address to grant access.


Usage
=====

~~~ruby
document = SheetsAPI.document("1xuQVCadaMmTPiz_13hXuZHGKDihc41w5aii4DtuxOmU5j_eQ4BD98T-H")
sheet = document.sheet("Daily Sales")
sheet.insert(
  index: [:Date, :Client],
  sort: true,
  upsert: true,
  rows: [
    {
      Date: Date.new(2017,3,9),
      Client: "Some Guy",
      Email: "guy@client.com",
      Sales: 14,
      Profit: 5
    },
    {
      Date: Date.new(2017,3,9),
      Client: "Other Guy",
      Sales: 2,
      Profit: -1
    },
    {
      Date: Date.new(2017,3,10),
      Client: "Some Guy",
      Email: "guy@client.com",
      Sales: 8,
      Margin: 3
    }
  ]
)
~~~

Insert Parameters
=================

Index
-----
The headers to use for upsert matching and sorting. Case sensitive. Default: []
If no index is provided, sort and upsert have no effect.

Sort
----
Sort the content of the sheet based on the index after all other operations are completed. Default: false

Upsert
------
Attempt to match given inputs to existing rows, based on the index. Default: false
If the index fields are the same, the data provided in the row parameter will override the existing row in the sheet.

Rows
----
An array of objects that represent rows to be updated. Default: []
Keys in the objects represent the header for the value. Keys are case sensitive.
The default behaviour is to insert new rows in the sheet for all provided rows.
Set the Upsert parameter to change to update instead.
It is not necessary to provide a value for every header value.
For the index headers, an empty value is considered "" for comparisons.
