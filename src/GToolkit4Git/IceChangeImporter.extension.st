Extension { #name : #IceChangeImporter }

{ #category : #'*GToolkit4Git' }
IceChangeImporter >> visitLepiterDatabaseChange: aLepiterDatabaseChange [
	| databaseSnapshot databaseDefinition databaseNode |
	
	"If the version does not include the knowledge base, we do not import it"
	(version 
		includesKnowledgeWithId: aLepiterDatabaseChange databaseUuid)
			ifFalse: [ ^ self ].
	
	databaseSnapshot := version 
		snapshotForKnowledgeWithId: aLepiterDatabaseChange databaseUuid.
	
	databaseDefinition := GtLepiterDatabaseDefinition new
		databaseId: databaseSnapshot databaseUuid;
		name: databaseSnapshot databaseName.
	
	databaseNode := parentNode addChild: databaseDefinition.

	databaseSnapshot pageSnapshots do: [ :aPageSnapshot |
		| pageDefinition |
		pageDefinition := GtLepiterPageDefinition new
			name: aPageSnapshot pageTitle;
			pageUuid: aPageSnapshot pageUuid;
			pageContents: aPageSnapshot pageContents.
		databaseNode addChild: pageDefinition ]
]
