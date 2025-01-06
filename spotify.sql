--Spotify Database--

DROP TABLE IF EXISTS spotify;
CREATE TABLE spotify (
    artist VARCHAR(255),
    track VARCHAR(255),
    album VARCHAR(255),
    album_type VARCHAR(50),
    danceability FLOAT,
    energy FLOAT,
    loudness FLOAT,
    speechiness FLOAT,
    acousticness FLOAT,
    instrumentalness FLOAT,
    liveness FLOAT,
    valence FLOAT,
    tempo FLOAT,
    duration_min FLOAT,
    title VARCHAR(255),
    channel VARCHAR(255),
    views FLOAT,
    likes BIGINT,
    comments BIGINT,
    licensed BOOLEAN,
    official_video BOOLEAN,
    stream BIGINT,
    energy_liveness FLOAT,
    most_played_on VARCHAR(50)
);

-- Exploratory Data Analysis --

SELECT count(*) from spotify; --All the songs--
SELECT count(distinct artist) from spotify; --All the unique artists--
SELECT count (distinct album) from spotify; --All the albums--
SELECT distinct album_type from spotify; --different types of albums--
SELECT max(duration_min) from spotify; --maximum duration of a song --
SELECT min(duration_min) from spotify; -- min duration of a song, but some came up with 0--

SELECT * FROM spotify
WHERE duration_min = 0;

DELETE FROM spotify
WHERE duration_min = 0; --bad rows, need to be cleaned--
/*
------------------------------------------------------------
--- Business Data Analysis from the Easy Category ----
------------------------------------------------------------
*/
--Retrieve the names of all tracks that have more than 1 billion streams.
SELECT track FROM spotify
WHERE stream > 1000000000;

--List all albums along with their respective artists.
SELECT DISTINCT artist, album FROM spotify
ORDER BY 1;

--Get the total number of comments for tracks where licensed = TRUE.
SELECT sum(comments) as total_comments FROM spotify
WHERE licensed = TRUE;

--Find all tracks that belong to the album type single.
SELECT track FROM spotify
WHERE album_type = 'single';

--Count the total number of tracks by each artist.
SELECT artist, count(track) as total_number_of_tracks FROM spotify
GROUP BY artist
ORDER BY 2 DESC;

/*
------------------------------------------------------------
--- Business Data Analysis from the Medium Category ----
------------------------------------------------------------
*/

--Calculate the average danceability of tracks in each album.
SELECT album, avg(danceability) FROM spotify
GROUP BY album
ORDER BY 2 DESC;

--Find the top 5 tracks with the highest energy values.
SELECT track, energy FROM spotify
ORDER BY energy DESC
LIMIT 5;

--List all tracks along with their views and likes where official_video = TRUE. Here, one track can be sung by 2 artists - so those will be double counted
SELECT track, avg(views), avg(likes) FROM spotify
WHERE official_video = TRUE
GROUP BY track
ORDER BY 2 DESC;

--For each album, calculate the total views of all associated tracks.
SELECT album, sum(views) as total_album_views FROM spotify
GROUP BY album, track
ORDER BY 2 DESC;

sum(views) as total_album_views FROM spotify
GROUP BY album
ORDER BY 2 DESC;

--Retrieve the track names that have been streamed on Spotify more than YouTube.
SELECT track, stream FROM spotify
WHERE most_played_on LIKE 'Youtube';

/*
------------------------------------------------------------
--- Business Data Analysis from the Hard Category ----
------------------------------------------------------------
*/
--Find the top 3 most-viewed tracks for each artist using window functions.
/*
First we group by artist and track to get the actual total views
Then we Dense rank the tracks by the artist
Then create a CTE (Common Table Expression) - like a little temporary view and only choose ranks below 3 - one continous SQL
*/
WITH artist_track_ranking AS (
SELECT artist, track, sum(views), DENSE_RANK() OVER (PARTITION BY artist ORDER BY sum(views) DESC) FROM spotify
GROUP BY artist, track
ORDER BY 1,3 DESC)

SELECT * FROM artist_track_ranking
WHERE dense_rank <=3;

--Write a query to find tracks where the liveness score is above the average.
SELECT track, artist, liveness FROM spotify
WHERE liveness > (SELECT avg(liveness) FROM spotify);

--Use a WITH clause to calculate the difference between the highest and lowest energy values for tracks in each album.
WITH energy_levels AS 
(SELECT artist, album, max(energy) as highest_energy, min(energy) as lowest_energy FROM spotify
GROUP BY album, artist
ORDER BY 1)

SELECT artist, album, abs(highest_energy - lowest_energy) as energy_difference FROM energy_levels
ORDER BY 3 DESC;

--Find tracks where the energy-to-liveness ratio is greater than 1.2.
WITH calculated_ratio AS
(SELECT track, energy/liveness as energy_to_liveliness_ratio FROM spotify)

SELECT * FROM calculated_ratio
WHERE energy_to_liveliness_ratio > 1.2
ORDER BY 2 DESC;

--Calculate the cumulative sum of likes for tracks ordered by the number of views, using window functions.
WITH TrackLikes AS (
SELECT track, artist, SUM(likes) AS total_likes, MAX(views) AS max_views FROM spotify
GROUP BY track, artist),
RankedTracks AS (
SELECT track, artist, total_likes, max_views,
     ROW_NUMBER() OVER (PARTITION BY track ORDER BY total_likes DESC, max_views DESC) AS row_num
    FROM TrackLikes
)
SELECT track, artist,total_likes, max_views FROM RankedTracks
WHERE row_num = 1
ORDER BY max_views DESC;

/*
------------------------------------------------------------
--- Query Optimization ----
------------------------------------------------------------
*/

EXPLAIN ANALYZE --Originally 750 ms to 1.3 ms
SELECT artist, track, views FROM SPOTIFY 
WHERE artist = 'Gorillaz' AND most_played_on = 'Youtube'
ORDER BY stream LIMIT 25;

CREATE INDEX artist_index on spotify(artist); 

