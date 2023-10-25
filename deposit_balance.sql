WITH max_rev_q AS  
     -- najnowszy wpis w historii users.deposit
         (
         SELECT 
       		id AS deposit_id,
       		max(rev) AS max_rev
         FROM version.users_deposit
         WHERE 
         	(version_date_at BETWEEN '2021-01-01' AND '2023-10-01')
         	AND deleted_at IS NULL   
         GROUP BY deposit_id
          )
SELECT 
	d.id, 
	d.rev, 
	d.version_date_at,
    d.user_id, 
    id."name",
    id.nip,
    id.deleted_at,
    d.bank_client_id AS IPH, 
    d.deposit_account_number, 
    d.settlement_account_number,
    d.deposit_amount, 
    d.overpaid_amount, 
    d.secured_amount, 
    d.created_at AS deposit_created_at,
    d.deleted_at 
FROM 
    "version".users_deposit d
    JOIN users.deposit d2 ON d2.id = d.id
    JOIN users.invoice_data id ON id.user_id = d.user_id 
WHERE 
	d.rev IN (SELECT max_rev FROM max_rev_q) AND 
	(d2.deleted_at IS NULL OR d2.deleted_at  > '2023-10-01')  -- sprawdzenie czy user miał w tym dniu depozyt
	AND d.deposit_amount > 0
	AND (id.deleted_at IS NULL OR id.deleted_at > '2023-10-01') -- sprawdzenie czy user miał dane do faktury
	;