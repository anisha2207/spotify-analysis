SELECT 
    'Danceability' AS feature, CORR(Danceability, Views + Likes) AS correlation
FROM spotify
UNION ALL
SELECT 
    'Energy', CORR(Energy, Views + Likes)
FROM spotify
UNION ALL
SELECT 
    'Liveness', CORR(Liveness, Views + Likes)
FROM spotify
UNION ALL
SELECT 
    'Acousticness', CORR(Acousticness, Views + Likes)
FROM spotify
UNION ALL
SELECT 
    'Speechiness', CORR(Speechiness, Views + Likes)
FROM spotify;


