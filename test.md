### Question 1
You are working with a database table that contains data about playlists for different types of digital media. 
The table includes columns for playlist_id and name. 
You want to remove duplicate entries for playlist names and sort the results by playlist ID. 
```
SELECT 
 DISTINCT name
FROM
 playlist
ORDER BY
 playlist_id;
```
