WITH synced_hotels AS (
    SELECT DISTINCT
        hcss.hotel_id,
        hcss.echannel_id
    FROM hotels_hotelechannelsyncstat hcss
    WHERE hcss.last_write_at >= DATE '2026-06-23'
)

SELECT
    cm.id AS channel_manager_id,
    cm.legal_cell AS channel_manager_legal_cell,
    cm.name AS channel_manager_name,

    COUNT(DISTINCT h.id) AS published_hotels_count,

    COUNT(DISTINCT CASE
        WHEN sh.hotel_id IS NOT NULL THEN h.id
    END) AS synced_hotels_count,

    ROUND(
        100.0
        * COUNT(DISTINCT CASE
            WHEN sh.hotel_id IS NOT NULL THEN h.id
          END)
        / NULLIF(COUNT(DISTINCT h.id), 0),
        2
    ) AS synced_percent,

    ARRAY_AGG(DISTINCT h.id)
        FILTER (WHERE sh.hotel_id IS NOT NULL)
        AS synced_hotel_ids,

    ARRAY_AGG(DISTINCT h.id)
        FILTER (WHERE sh.hotel_id IS NULL)
        AS not_synced_hotel_ids

FROM echannel_echannelprofile cm

JOIN hotels_hotel h
    ON h.channel_manager_id = cm.id
   AND h.status = 'P'
   AND h.legal_cell = 'global'

LEFT JOIN synced_hotels sh
    ON sh.hotel_id = h.id
   AND sh.echannel_id = cm.id

WHERE cm.status = 'active'
  AND cm.legal_cell = 'global'

GROUP BY
    cm.id,
    cm.legal_cell,
    cm.name

HAVING COUNT(DISTINCT h.id) > 0

ORDER BY
    synced_percent DESC,
    published_hotels_count DESC;