CREATE TABLE IF NOT EXISTS `properties` (
	`id` INT(20) AUTO_INCREMENT,
	`shell` TEXT(100) NOT NULL DEFAULT '',
	`enter_coords` TEXT(100) NOT NULL DEFAULT '',
	PRIMARY KEY (`id`)
);

CREATE TABLE IF NOT EXISTS `properties_furnitures` (
	`id` INT(20) AUTO_INCREMENT,
	`property_id` INT(20) NOT NULL,
	`model` TEXT(100) NOT NULL,
	`coords` TEXT(100) NOT NULL,
	`rotation` TEXT(100) NOT NULL,
	PRIMARY KEY (`id`)
);

CREATE TABLE IF NOT EXISTS `properties_layouts` (
	`id` INT(20) AUTO_INCREMENT,
	`identifier` VARCHAR(80) NOT NULL,
	`shell` TEXT(100) NOT NULL,
	`name` TEXT NOT NULL,
	`furnitures` MEDIUMTEXT NOT NULL DEFAULT '{}',
	PRIMARY KEY (`id`)
);