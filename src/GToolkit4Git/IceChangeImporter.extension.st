Extension { #name : #IceChangeImporter }

{ #category : #'*GToolkit4Git' }
IceChangeImporter >> visitLepiterDatabaseChange: aLepiterDatabaseChange [
	| databaseDefinition databaseNode |
	databaseDefinition := GtLepiterDatabaseDefinition new
		databaseId: aLepiterDatabaseChange database uuid;
		name: aLepiterDatabaseChange database databaseName.
		
	databaseNode := parentNode addChild: databaseDefinition.

	aLepiterDatabaseChange database pages do: [ :aPage |
		| pageDefinition |
		pageDefinition := GtLepiterPageDefinition new
			name: aPage title;
			pageUuid: aPage uid.
		databaseNode addChild: pageDefinition ]
]
