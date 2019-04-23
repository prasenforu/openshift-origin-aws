# Graph from CSV

An example repository for creating website graphs from CSV files. This repository uses c3.js and PapaParse.
To create a graph from report csv file.

### Graph/Chart Library
c3.js: http://c3js.org/

### CSV/JSON Parsing Library
PapaParse: http://papaparse.com/

### Only Requirement
You need a web server. I used python to initiate a web server.

```
python --version
Python 2.7.10
```

```
cd graphs-from-csv/
python -m SimpleHTTPServer
```

Visit http://localhost:7000 to see the website.

### Docker build

```docker build -t csv2graph:1.0 .```

### Docker run

```docker run -p 7000:7000 -d csv2graph:1.0```

### Tutorial

https://www.youtube.com/watch?v=1OK4TJfCzdY



