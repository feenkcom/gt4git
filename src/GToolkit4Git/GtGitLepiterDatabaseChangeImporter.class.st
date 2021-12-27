Class {
	#name : #GtGitLepiterDatabaseChangeImporter,
	#superclass : #Object,
	#instVars : [
		'version',
		'lepiterDatabaseChange'
	],
	#category : #'GToolkit4Git-Lepiter'
}

{ #category : #accessing }
GtGitLepiterDatabaseChangeImporter >> createDatabaseNodeOn: aParentNode [
	| databaseDefinition databaseNode |
	databaseDefinition := GtLepiterDatabaseDefinition new
		name: lepiterDatabaseChange database databaseName;
		databaseId: lepiterDatabaseChange database uuid;
		localRootRelativePath: (RelativePath with:
			lepiterDatabaseChange database localStoreRootDirectory basename).
	
	databaseNode	 := aParentNode addChild: databaseDefinition.
	lepiterDatabaseChange propertiesFile ifNotNil: [
		| fileReference |
		fileReference := version resolveDelta: lepiterDatabaseChange propertiesFile delta.
		fileReference exists ifTrue: [
			databaseNode addChild: (GtLepiterDatabasePropertiesDefinition new
				name: fileReference basename;
				fileName: fileReference basename;
				fileContents: fileReference contents) ] ].
		
	^ databaseNode
]

{ #category : #accessing }
GtGitLepiterDatabaseChangeImporter >> importAttachmentDefinitionFor: anAttachmentChange on: anAttachmentsNode [
	| attachmentDefinition attachmentNode |
		
	attachmentDefinition := GtLepiterAttachmentDefinition new 
		name: anAttachmentChange uuidString.
	attachmentNode := anAttachmentsNode addChild: attachmentDefinition.
	
	anAttachmentChange propertiesChange ifNotNil: [
		self 
			importAttachmentPropertiesDefinitionFor: anAttachmentChange propertiesChange 
			on: attachmentNode ].
	anAttachmentChange fileChanges do: [ :aFileChange | 
		self 
			importAttachmentFileDefinitionFor: aFileChange 
			on: attachmentNode ].
]

{ #category : #accessing }
GtGitLepiterDatabaseChangeImporter >> importAttachmentDefinitionsOn: databaseNode [
	| attachmentsDefinition attachmentsNode |
	attachmentsDefinition := GtLepiterAttachmentsDefinition new.
	attachmentsNode := databaseNode addChild: attachmentsDefinition.
	
	(lepiterDatabaseChange attachments 
		select: [ :anAttachmentChange | 
			(version fileSystem resolve: anAttachmentChange path) exists ])
		do: [ :anAttachmentChange | 
				self 
					importAttachmentDefinitionFor: anAttachmentChange 
					on: attachmentsNode ] 
]

{ #category : #accessing }
GtGitLepiterDatabaseChangeImporter >> importAttachmentFileDefinitionFor: aFileChange on: anAttachmentNode [
	| fileReference attachmentFileDefinition |
	fileReference := version resolveDelta: aFileChange delta.
	fileReference exists ifFalse: [ ^ self ].
	
	attachmentFileDefinition := GtLepiterAttachmentFileDefinition new
		name: fileReference basename;
		fileName: fileReference basename;
		binaryContents: fileReference gtBinaryContents.
	anAttachmentNode addChild: attachmentFileDefinition
]

{ #category : #accessing }
GtGitLepiterDatabaseChangeImporter >> importAttachmentPropertiesDefinitionFor: aPropertiesFileChange on: anAttachmentNode [ 
	| fileReference attachmentFileDefinition |
	fileReference := version resolveDelta: aPropertiesFileChange delta.
	fileReference exists ifFalse: [ ^ self ].
	
	attachmentFileDefinition := GtLepiterAttachmentPropertiesDefinition new
		name: fileReference basename;
		fileName: fileReference basename;
		fileContents: fileReference contents.
	anAttachmentNode addChild: attachmentFileDefinition
]

{ #category : #accessing }
GtGitLepiterDatabaseChangeImporter >> importOn: aParentNode [
	| databaseNode |
	databaseNode := self createDatabaseNodeOn: aParentNode.
	self importPageDefinitionsOn: databaseNode.
	self importAttachmentDefinitionsOn: databaseNode
]

{ #category : #accessing }
GtGitLepiterDatabaseChangeImporter >> importPageDefinitionsOn: databaseNode [
	| pagesDefinition pagesNode |
	pagesDefinition := GtLepiterPagesDefinition new.
	pagesNode := databaseNode addChild: pagesDefinition.
	lepiterDatabaseChange pages do: [ :aPageChange | 
		| fileReference pageDefinition page contents |
		fileReference := version resolveDelta: aPageChange delta.
		fileReference exists ifTrue: [ 
			contents := fileReference contents.
			page := LeJsonV4 uniqueInstance 
				deserialize: fileReference readStream.
			pageDefinition := GtLepiterPageDefinition new
				name: page title;
				fileName: fileReference basename;
				pageUuid: page uid;
				pageContents: contents.
			pagesNode addChild: pageDefinition ] ]
]

{ #category : #accessing }
GtGitLepiterDatabaseChangeImporter >> lepiterDatabaseChange: aLepiterDatabaseChange [
	lepiterDatabaseChange := aLepiterDatabaseChange
]

{ #category : #accessing }
GtGitLepiterDatabaseChangeImporter >> version: aVersion [
	version := aVersion
]
