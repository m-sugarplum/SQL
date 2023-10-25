SELECT params::json ->> 'correctionCause' AS return_reason, count(id) 
FROM "subscription".charge_request
WHERE remote_id <> remote_parent_id 
AND realized_at BETWEEN '2023-01-01' AND '2023-08-01'
AND status = 'DONE_OK'
AND trans_ref ~ '^[ZWR]'
AND product_code = 'A4 Katowice - Kraków'
GROUP BY return_reason;