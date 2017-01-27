SELECT eib_electrodes.channel,
eib_electrodes.site,
session_electrodes.ap,
session_electrodes.ml,
session_electrodes.dv,
session_electrodes.region_id,
session_electrodes.valid
FROM sessions
INNER JOIN session_electrodes ON session_electrodes.session_id = sessions.id
INNER JOIN eib_electrodes ON eib_electrodes.id = session_electrodes.eib_electrodes_id
WHERE sessions.name = "R0088_20151101a"