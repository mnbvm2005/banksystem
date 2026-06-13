USE banksystem;

UPDATE users
SET username = '1',
    password = '1',
    phone = '1',
    status = 1
WHERE id = 1;

UPDATE users
SET username = '2',
    password = '1',
    phone = '2',
    status = 1
WHERE id = 2;

UPDATE accounts
SET reserved_phone = '1'
WHERE user_id = 1;

UPDATE accounts
SET reserved_phone = '2'
WHERE user_id = 2;
