SELECT subjects.id AS 'subjects__id',
subjects.name AS 'subjects__name'
FROM sessions
INNER JOIN subjects ON sessions.subject_id = subjects.id
WHERE sessions.name = "%s"