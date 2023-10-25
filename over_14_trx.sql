WITH id_fees_september AS (
		SELECT id
		FROM payments.fee 
		WHERE 
			sale_date = '2023-08-31' 
			AND fee_amount > 0
			AND payment_status = 'PAID')
SELECT DISTINCT 
	to_char(i.created_at, 'Month') AS fee_month, 	
	i.user_id, 
	id.product_number AS fee_id,
	cs.card_id,
	count(i.id) AS trx_count,  -- liczba prób obciążeń karty
	ROW_NUMBER () OVER () AS row_counter  --liczba opłat za abonament z >14 próbami obciążenia karty
FROM payments.in_detail id
JOIN payments."in" i ON id.payment_in_id = i.id
JOIN users.card_service cs ON cs.id = i.card_service_id
WHERE 
    i.created_at BETWEEN '2023-09-01' AND '2023-10-01'
    AND i.channel = 'PAYMENT_CARD'
    AND i.is_fee = TRUE 
    AND is_pbl = FALSE
    AND product_number IN (SELECT id::text FROM id_fees_september)
GROUP BY 
    i.user_id, 
    id.product_number, 
    fee_month, 
    cs.card_id
HAVING count(i.id) > 14
ORDER BY row_num DESC;