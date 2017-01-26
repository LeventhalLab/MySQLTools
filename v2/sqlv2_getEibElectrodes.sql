SELECT eib_electrodes.site as 'eib_electrodes__site',
eib_electrodes.channel as 'eib_electrodes__channel'
FROM subjects
INNER JOIN eib_electrodes ON subjects.eib_map_id = eib_electrodes.eib_map_id
WHERE subjects.id = "%i"