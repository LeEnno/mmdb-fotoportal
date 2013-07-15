CREATE FULLTEXT INDEX fulltext_title    ON pictures(title);
CREATE FULLTEXT INDEX fulltext_camera   ON pictures(camera);
CREATE FULLTEXT INDEX fulltext_location ON pictures(location);
CREATE FULLTEXT INDEX fulltext_keywords ON keywords(name);
CREATE FULLTEXT INDEX fulltext_persons  ON persons(name);

ALTER TABLE sessions          ADD FOREIGN KEY (user_id)    REFERENCES users(id);
ALTER TABLE folders           ADD FOREIGN KEY (user_id)    REFERENCES users(id);
ALTER TABLE pictures          ADD FOREIGN KEY (folder_id)  REFERENCES folders(id);
ALTER TABLE keywords_pictures ADD FOREIGN KEY (picture_id) REFERENCES pictures(id),
                              ADD FOREIGN KEY (keyword_id) REFERENCES keywords(id);
ALTER TABLE appearances       ADD FOREIGN KEY (picture_id) REFERENCES pictures(id),
                              ADD FOREIGN KEY (person_id)  REFERENCES persons(id);