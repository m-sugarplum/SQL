WITH fees_and_crs AS (
  SELECT
		cs.user_id,
		cs.card_id,
		count(i.id) AS trx_count
  FROM users.card_service cs
  JOIN payments."in" i ON i.card_service_id = cs.id
  JOIN "subscription".charge_request cr ON cr.payment_in_id = i.id
  WHERE i.created_at BETWEEN '2022-06-01' AND '2023-07-01'
        AND cs.card_id IN ( {lista card.id} )
        AND i.payment_status = 'PAID'
  GROUP BY cs.user_id, cs.card_id
  UNION SELECT 
		cs.user_id,
		cs.card_id,
		count(i.id)
  FROM users.card_service cs
  JOIN payments."in" i ON i.card_service_id = cs.id
  JOIN payments.fee f ON f.in_id = i.id
  WHERE i.created_at BETWEEN '2022-06-01' AND '2023-07-01'
        AND cs.card_id IN ( {lista card.id} )
        AND i.payment_status = 'PAID'
  GROUP BY cs.user_id, cs.card_id 
  )
SELECT 
      user_id, 
      card_id,  
      sum(trx_count) AS transaction_count
FROM fees_and_crs
GROUP BY user_id, card_id
ORDER BY transaction_count DESC;