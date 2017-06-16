SELECT eib_electrodes.site,
eib_electrodes.channel,
session_electrodes.ap,
session_electrodes.ml,
session_electrodes.dv,
session_electrodes.region_id,
session_electrodes.valid,
regions.name,
regions.abbreviation
FROM sessions
INNER JOIN subjects ON sessions.subject_id = subjects.id
INNER JOIN session_electrodes ON session_electrodes.session_id = sessions.id
INNER JOIN eib_electrodes ON eib_electrodes.site = session_electrodes.eib_site
INNER JOIN regions ON session_electrodes.region_id = regions.id
WHERE sessions.name = "%s" AND subjects.eib_map_id = eib_electrodes.eib_map_id