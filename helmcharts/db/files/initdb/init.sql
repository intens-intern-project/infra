create database db;

create table counters (
    id      serial primary key,
    name    varchar unique,
    value   integer default 0
);

insert into counters (name, value) values ('default', 0);