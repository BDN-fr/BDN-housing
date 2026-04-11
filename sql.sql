CREATE TABLE IF NOT EXISTS `properties` (
	`id` INT UNSIGNED AUTO_INCREMENT,
	`shell` TEXT NOT NULL DEFAULT '',
	`enter_coords` TEXT NULL DEFAULT '',
	`storage_coords` TEXT DEFAULT NULL,
	`key_code` INT NOT NULL,
	`stack` INT UNSIGNED DEFAULT NULL,
	PRIMARY KEY (`id`)
);

CREATE TABLE IF NOT EXISTS `properties_stacks` (
	`id` INT UNSIGNED AUTO_INCREMENT,
	`enter_coords` TEXT NOT NULL DEFAULT '',
	PRIMARY KEY (`id`)
);

CREATE TABLE IF NOT EXISTS `properties_furnitures` (
	`id` INT UNSIGNED AUTO_INCREMENT,
	`property_id` INT NOT NULL,
	`model` TEXT NOT NULL,
	`coords` TEXT NOT NULL,
	`rotation` TEXT NOT NULL,
	`matrix` TEXT,
	PRIMARY KEY (`id`)
);

CREATE TABLE IF NOT EXISTS `properties_layouts` (
	`id` INT UNSIGNED AUTO_INCREMENT,
	`identifier` VARCHAR(80) NOT NULL,
	`shell` TEXT NOT NULL,
	`name` TEXT NOT NULL,
	`furnitures` MEDIUMTEXT NOT NULL DEFAULT '{}',
	PRIMARY KEY (`id`)
);

CREATE TABLE IF NOT EXISTS `properties_keys` (
	`identifier` VARCHAR(60) NOT NULL COLLATE 'utf8mb3_general_ci',
	`property_id` INT UNSIGNED NOT NULL,
	`key_code` INT NOT NULL,
	PRIMARY KEY (`identifier`, `property_id`, `key_code`) USING BTREE
);