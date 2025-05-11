CREATE TABLE IF NOT EXISTS `properties` (
	`id` INT AUTO_INCREMENT,
	`shell` TEXT NOT NULL DEFAULT '',
	`enter_coords` TEXT NOT NULL DEFAULT '',
	`storage_coords` TEXT DEFAULT NULL,
	`key_code` INT NOT NULL,
	PRIMARY KEY (`id`)
);

CREATE TABLE IF NOT EXISTS `properties_furnitures` (
	`id` INT AUTO_INCREMENT,
	`property_id` INT NOT NULL,
	`model` TEXT NOT NULL,
	`coords` TEXT NOT NULL,
	`rotation` TEXT NOT NULL,
	`matrix` TEXT,
	PRIMARY KEY (`id`)
);

CREATE TABLE IF NOT EXISTS `properties_layouts` (
	`id` INT AUTO_INCREMENT,
	`identifier` VARCHAR(80) NOT NULL,
	`shell` TEXT NOT NULL,
	`name` TEXT NOT NULL,
	`furnitures` MEDIUMTEXT NOT NULL DEFAULT '{}',
	PRIMARY KEY (`id`)
);