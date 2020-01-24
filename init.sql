SET NAMES 'utf8';
CREATE DATABASE `janusz`;
ALTER SCHEMA `janusz` DEFAULT CHARACTER SET utf8mb4 DEFAULT COLLATE utf8mb4_bin;
USE janusz;
CREATE TABLE `brain`
(
    `id`   int(11) NOT NULL,
    `data` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin,
    PRIMARY KEY (`id`)
) ENGINE = InnoDB
  DEFAULT CHARSET = utf8mb4;

