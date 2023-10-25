
SELECT 
	(SELECT count(cr.id)
	FROM "subscription".charge_request cr 
	JOIN "subscription"."subscription" s ON cr.subscription_id = s.id
	WHERE 
		cr.created_at BETWEEN '2023-09-01' AND '2023-10-01'
		AND cr.count_repeat_payment = 1
		AND charge_request_type = 'TRIP'
		AND CR.status = 'DONE_OK'
		AND payment_source = 'PAYMENT_CARD'
		AND payment_source_at < '2023-09-01'
	 	AND amount > 0 ) AS opłacone_za_1_razem,
	(SELECT count(cr.id)
		FROM "subscription".charge_request cr 
		JOIN "subscription"."subscription" s ON cr.subscription_id = s.id
		WHERE cr.created_at BETWEEN '2023-09-01' AND '2023-10-01'
			AND cr.count_repeat_payment BETWEEN 2 AND 14
			AND charge_request_type = 'TRIP'
			AND CR.status = 'DONE_OK'
			AND payment_source = 'PAYMENT_CARD'
			AND payment_source_at < '2023-09-01'
		 	AND amount > 0) AS między_2_a_14,
	(SELECT count(cr.id)
	FROM "subscription".charge_request cr 
	JOIN "subscription"."subscription" s ON cr.subscription_id = s.id
	WHERE cr.created_at BETWEEN '2023-09-01' AND '2023-10-01'
		AND cr.count_repeat_payment > 14
		AND charge_request_type = 'TRIP'
		AND CR.status = 'DONE_OK'
		AND payment_source = 'PAYMENT_CARD'
		AND payment_source_at < '2023-09-01'
	 	AND amount > 0) AS powyżej_14,
	(SELECT count(cr.id)
		FROM "subscription".charge_request cr 
		JOIN "subscription"."subscription" s ON cr.subscription_id = s.id
		WHERE cr.created_at BETWEEN '2023-09-01' AND '2023-10-01'
			AND charge_request_type = 'TRIP'
			AND CR.status = 'DONE_OK'
			AND payment_source = 'PAYMENT_CARD'
			AND payment_source_at < '2023-09-01'
		 	AND amount > 0) AS wszystkie_trx_za_przejazdy;

