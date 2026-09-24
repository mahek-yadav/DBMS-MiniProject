
create database BloodBankNetwork;

create table donor (
    donor_id Serial primary key,
    first_name varchar(50) not null,
    last_name varchar(50) not null,
    blood_group varchar(5) not null check (blood_group in ('A+','A-','B+','B-','AB+','AB-','O+','O-')),
    gender char(1) not null check (gender in ('M','F','O')),
    dob date not null,
    phone varchar(15) not null unique,
    email varchar(100) unique,
    city varchar(50) not null
);


create table blood_bank (
    bank_id Serial primary key,
    bank_name varchar(100) not null,
    city varchar(50) not null,
    phone varchar(15) not null unique
);


create table donation (
    donation_id Serial primary key,
    donor_id int not null,
    bank_id int not null,
    donation_date date not null default current_date,
    foreign key (donor_id) references donor(donor_id),
    foreign key (bank_id) references blood_bank(bank_id)
);


create table hospital (
    hospital_id Serial primary key,
    hospital_name varchar(100) not null,
    city varchar(50) not null,
    phone varchar(15) not null unique
);


create table blood_unit (
    unit_id Serial primary key,
    donation_id int not null,
    blood_group varchar(5) not null check (blood_group in ('A+','A-','B+','B-','AB+','AB-','O+','O-')),
    volume_ml int not null check (volume_ml > 0),
    status varchar(10) not null default 'available' check (status in ('available','reserved','issued','expired')),
    bank_id int not null,
    issued_to_hospital int,
    foreign key (donation_id) references donation(donation_id),
    foreign key (bank_id) references blood_bank(bank_id),
    foreign key (issued_to_hospital) references hospital(hospital_id)
);


create table hospital_request (
    request_id Serial primary key,
    hospital_id int not null,
    blood_group varchar(5) not null check (blood_group in ('A+','A-','B+','B-','AB+','AB-','O+','O-')),
    units_requested int not null check (units_requested > 0),
    request_date date not null default current_date,
    status varchar(10) not null default 'pending' check (status in ('pending','fulfilled','partial')),
    foreign key (hospital_id) references hospital(hospital_id)
);
