SELECT nas_servers.host AS 'nas_server__host', 
nas_folders.path AS 'nas_folders__path',
experiments.name AS 'experiments__name' 
FROM subjects 
INNER JOIN nas_folders ON subjects.nas_folder_id = nas_folders.id
INNER JOIN nas_servers ON nas_folders.nas_server_id = nas_servers.id
INNER JOIN experiments ON experiments.id = subjects.experiment_id
WHERE subjects.name = "%s";