-- auto-generated definition
create table materials
(
    id       INTEGER
        primary key autoincrement,
    name     TEXT              not null,
    location TEXT,
    quantity INTEGER default 0 not null,
    memo     TEXT
);

-- auto-generated definition
create table warehouses
(
    id   INTEGER
        primary key autoincrement,
    name TEXT not null
        unique,
    memo TEXT
);

