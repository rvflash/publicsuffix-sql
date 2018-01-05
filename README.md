# Public Suffix for MySql

Mysql's functions to parse domain names based on the Public Suffix List.


## Installation

```bash
$ git clone https://github.com/rvflash/publicsuffix-sql
```


## Testing

Go into the source directory and starts the Docker.

```bash
$ cd publicsuffix-sql
$ docker-compose up
$ docker exec -ti $(docker ps -lq) bash
```

In the new prompt, opens the MySql client: 

```bash
$ mysql -h db -u root -ps3cr3tp4ssw0rd ps
```


## Features

* The function named `hostname` extracts the hostname in a URL.
* Function named `domain` returns the hostname without the sub-domain (ex: google.com.au).
* The `sld` and `tld` functions returns respectively the second level domain (ex: com.au) and top level domain (ex: au). 

```
> select hostname("https://www.google.com.au/search?q=golang");
+-------------------------------------------------------+
| hostname("https://www.google.com.au/search?q=golang") |
+-------------------------------------------------------+
| www.google.com.au                                     |
+-------------------------------------------------------+
1 row in set (0.00 sec)

> select domain("https://www.google.com.au/");
+--------------------------------------+
| domain("https://www.google.com.au/") |
+--------------------------------------+
| google.com.au                        |
+--------------------------------------+
1 row in set (0.00 sec)

> select sld(domain("https://www.google.com.au/"));
+-------------------------------------------+
| sld(domain("https://www.google.com.au/")) |
+-------------------------------------------+
| com.au                                    |
+-------------------------------------------+
1 row in set (0.00 sec)
```
