-- Creates the workspace.
CREATE TABLE IF NOT EXISTS public_suffix (
  suffix varchar(255) not null,
  primary key (suffix)
) engine=InnoDB default charset=utf8 collate=utf8_general_ci;

-- Loads the public suffix list.
LOAD DATA LOCAL INFILE '/opt/public-suffix/registry.dat'
IGNORE INTO TABLE public_suffix
LINES TERMINATED BY '\n';

DELIMITER $$

-- Extracts the hostname, like `www.rv.net`
-- Sample: http://username:password@hostname:9090/path?arg=value#anchor
DROP FUNCTION IF EXISTS HOSTNAME;
CREATE FUNCTION HOSTNAME (uri VARCHAR(255) CHARSET utf8)
  RETURNS VARCHAR(255) CHARSET utf8 NO SQL
  BEGIN
    DECLARE host VARCHAR(255) CHARSET utf8;
    -- removes the scheme
    SET host = SUBSTRING_INDEX(uri, '://', -1);
    -- removes all chars before [at]
    SET host = SUBSTRING_INDEX(host, '@', -1);
    -- removes all before the protocol
    SET host = SUBSTRING_INDEX(host, ':', 1);
    -- removes the path
    SET host = SUBSTRING_INDEX(host, '/', 1);
    RETURN host;
  END $$

-- Returns only the second level domain, like `co.uk`
DROP FUNCTION IF EXISTS SLD;
CREATE FUNCTION SLD (host VARCHAR(255) CHARSET utf8)
  RETURNS VARCHAR(50) CHARSET utf8 READS SQL DATA
  BEGIN
    DECLARE sld VARCHAR(50) CHARSET utf8;
    SELECT suffix INTO sld
      FROM public_suffix
      WHERE suffix = SUBSTRING_INDEX(host, '.',  -2);
    RETURN sld;
  END $$

-- Returns only the top level domain, like `fr`
DROP FUNCTION IF EXISTS TLD;
CREATE FUNCTION TLD (host VARCHAR(255) CHARSET utf8)
  RETURNS VARCHAR(5) CHARSET utf8 READS SQL DATA
  BEGIN
    DECLARE tld VARCHAR(5) CHARSET utf8;
    SELECT suffix INTO tld
      FROM public_suffix
      WHERE suffix = SUBSTRING_INDEX(host, '.',  -1);
    RETURN tld;
  END $$

-- Returns the root domain like `rv.net` for `www.rv.net`
DROP FUNCTION IF EXISTS DOMAIN;
CREATE FUNCTION DOMAIN (uri VARCHAR(255) CHARSET utf8)
  RETURNS VARCHAR(255) CHARSET utf8 READS SQL DATA
  BEGIN
    DECLARE root, host VARCHAR(255) CHARSET utf8;
    SET host = HOSTNAME(uri);
    SET root = TLD(host);
    IF root != '' THEN
      SET root = SLD(host);
      IF root != '' THEN
        SET root = SUBSTRING_INDEX(host, '.',  -3);
      ELSE
        SET root = SUBSTRING_INDEX(host, '.',  -2);
      END IF;
    END IF;
    RETURN root;
  END $$

DELIMITER ;