Extension { #name : #IceChangeImporter }

{ #category : #'*GToolkit4Git' }
IceChangeImporter >> visitLepiterDatabaseChange: aLepiterDatabaseChange [

	| databaseSnapshot databaseDefinition databaseNode pagesDefinition pagesNode attachmentsDefinition attachmentsNode |
	databaseDefinition := GtLepiterDatabaseDefinition new name:
		                      aLepiterDatabaseChange database databaseName.

	databaseNode := parentNode addChild: databaseDefinition.

	pagesDefinition := GtLepiterPagesDefinition new.
	pagesNode := databaseNode addChild: pagesDefinition.
	aLepiterDatabaseChange pages do: [ :aPageLocation | 
		| fileSystem fileReference pageDefinition page contents |
		fileSystem := version fileSystem.
		fileReference := (fileSystem isKindOf: FileReference)
			                 ifTrue: [ 
			                 version fileSystem resolve:
				                 aPageLocation oldFileRelative ]
			                 ifFalse: [ 
			                 (version fileSystem resolve: aPageLocation newFile)
				                 asFileReference ].

		contents := fileReference contents.
		page := LeJsonV4 uniqueInstance deserialize:
			        fileReference readStream.
		pageDefinition := GtLepiterPageDefinition new
			                  name: page title;
			                  pageUuid: page uid;
			                  pageContents: contents.
		pagesNode addChild: pageDefinition ]
]
