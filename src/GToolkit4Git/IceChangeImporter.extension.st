Extension { #name : #IceChangeImporter }

{ #category : #'*GToolkit4Git' }
IceChangeImporter >> visitLepiterDatabaseChange: aLepiterDatabaseChange [
	| databaseSnapshot databaseDefinition databaseNode pagesDefinition pagesNode attachmentsDefinition attachmentsNode |
	
	"If the version does not include the knowledge base, we do not import it"
	(version 
		includesKnowledgeWithId: aLepiterDatabaseChange databaseUuid)
			ifFalse: [ ^ self ].
	
	databaseSnapshot := version 
		snapshotForKnowledgeWithId: aLepiterDatabaseChange databaseUuid.
	
	databaseDefinition := GtLepiterDatabaseDefinition new
		databaseId: databaseSnapshot databaseUuid;
		name: databaseSnapshot databaseName;
		localRootRelativePath: databaseSnapshot localRootRelativePath.
	
	databaseNode := parentNode addChild: databaseDefinition.
	databaseNode addChild: (GtLepiterDatabasePropertiesDefinition new
		name: databaseSnapshot propertiesFileName;
		fileName: databaseSnapshot propertiesFileName;
		fileContents: databaseSnapshot propertiesContents).

	pagesDefinition := GtLepiterPagesDefinition new.
	pagesNode := databaseNode addChild: pagesDefinition.
	databaseSnapshot pageSnapshots do: [ :aPageSnapshot |
		| pageDefinition |
		pageDefinition := GtLepiterPageDefinition new
			name: aPageSnapshot pageTitle;
			pageUuid: aPageSnapshot pageUuid;
			pageContents: aPageSnapshot pageContents.
		pagesNode addChild: pageDefinition ].
	
	attachmentsDefinition := GtLepiterAttachmentsDefinition new
		name: 'attachments'.
	attachmentsNode := databaseNode addChild: attachmentsDefinition.
	databaseSnapshot attachmentSnapshots do: [ :anAttachmentSnapshot |
		| attachmentDefinition  attachmentNode |
		attachmentDefinition := GtLepiterAttachmentDefinition new
			name: anAttachmentSnapshot attachmentUuid asString36.
		attachmentNode := attachmentsNode addChild: attachmentDefinition.
		attachmentNode
			addChild: (GtLepiterAttachmentPropertiesDefinition new
				name: anAttachmentSnapshot propertiesFileName;
				fileName: anAttachmentSnapshot propertiesFileName;
				fileContents: anAttachmentSnapshot propertiesContents).
		(anAttachmentSnapshot fileSnapshots do: [ :aFileSnapshot |
				attachmentNode addChild: (GtLepiterAttachmentFileDefinition new
					name: aFileSnapshot fileName;
					fileName: aFileSnapshot fileName;
					binaryContents: aFileSnapshot binaryContents) ]) ]
]
