SET foreign_key_checks=0;

--
-- Table: `container`
--
CREATE TABLE `container` (
  `id` VARCHAR(64) NOT NULL,
  `ip` VARCHAR(64) NOT NULL,
  `hostname` VARCHAR(64) NOT NULL,
  `image` VARCHAR(64) NOT NULL,
  `status` TINYINT NOT NULL DEFAULT 0,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  UNIQUE INDEX `id_idx` (`id`),
  UNIQUE INDEX `ip_idx` (`ip`),
  UNIQUE `hostname_uniq` (`hostname`),
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARACTER SET utf8;

--
-- Table: `image`
--
CREATE TABLE `image` (
  `id` VARCHAR(64) NOT NULL,
  `repository` VARCHAR(64) NOT NULL,
  `tag` VARCHAR(64) NOT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  UNIQUE INDEX `id_idx` (`id`),
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARACTER SET utf8;

--
-- Table: `proxy`
--
CREATE TABLE `proxy` (
  `id` INTEGER unsigned NOT NULL auto_increment,
  `virtual_host` VARCHAR(64) NOT NULL,
  `listen_port` INTEGER NOT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  UNIQUE INDEX `id_idx` (`id`),
  INDEX `vh_port_idx` (`virtual_host`, `listen_port`),
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARACTER SET utf8;

--
-- Table: `container_proxy`
--
CREATE TABLE `container_proxy` (
  `id` INTEGER unsigned NOT NULL auto_increment,
  `proxy_id` INTEGER unsigned NOT NULL,
  `container_id` VARCHAR(64) NOT NULL,
  `proxy_port` INTEGER unsigned NOT NULL,
  `created_at` datetime NOT NULL,
  UNIQUE INDEX `id_idx` (`id`),
  INDEX `proxy_id_idx` (`proxy_id`),
  INDEX `container_id_idx` (`container_id`),
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARACTER SET utf8;

SET foreign_key_checks=1;

