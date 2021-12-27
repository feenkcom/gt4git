Class {
	#name : #GtGitLepiterDatabaseChangeImporter,
	#superclass : #Object,
	#instVars : [
		'version',
		'lepiterDatabaseChange'
	],
	#category : #'GToolkit4Git-Lepiter'
}

{ #category : #'nodes creation' }
GtGitLepiterDatabaseChangeImporter >> createDatabaseNodeOn: aParentNode [
	| databaseDefinition databaseNode |
	databaseDefinition := GtLepiterDatabaseDefinition new
		name: lepiterDatabaseChange databaseName;
		databaseId: lepiterDatabaseChange databaseUuid;
		localRootRelativePath: (RelativePath with:
			lepiterDatabaseChange database localStoreRootDirectory basename).
	
	databaseNode	 := aParentNode addChild: databaseDefinition.
	lepiterDatabaseChange propertiesFileChange ifNotNil: [
		| fileReference |
		fileReference := version resolveDelta: lepiterDatabaseChange propertiesFileChange delta.
		fileReference exists ifTrue: [
			databaseNode addChild: (GtLepiterDatabasePropertiesDefinition new
				name: fileReference basename;
				fileName: fileReference basename;
				fileContents: fileReference contents) ] ].
		
	^ databaseNode
]

{ #category : #'definitions importing' }
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

{ #category : #'definitions importing' }
GtGitLepiterDatabaseChangeImporter >> importAttachmentDefinitionsOn: databaseNode [
	| attachmentsDefinition attachmentsNode |
	attachmentsDefinition := GtLepiterAttachmentsDefinition new.
	attachmentsNode := databaseNode addChild: attachmentsDefinition.
	
	(lepiterDatabaseChange attachmentChanges
		select: [ :anAttachmentChange | 
			(version fileSystem resolve: anAttachmentChange path) exists ])
		do: [ :anAttachmentChange | 
				self 
					importAttachmentDefinitionFor: anAttachmentChange 
					on: attachmentsNode ] 
]

{ #category : #'definitions importing' }
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

{ #category : #'definitions importing' }
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

{ #category : #'definitions importing' }
GtGitLepiterDatabaseChangeImporter >> importLinksDefinitionOn: aDatabaseNode [
	| fileReference linksDefinition |
	
	lepiterDatabaseChange linksChange ifNil: [ ^ self ].
	
	fileReference := version 
		resolveDelta: lepiterDatabaseChange linksChange delta.
	fileReference exists ifFalse: [ ^ self ].
	
	linksDefinition := GtLepiterLinksDefinition new
		name: fileReference basename;
		linksFileName: fileReference basename;
		linksContents: fileReference contents.
	aDatabaseNode addChild: linksDefinition
]

{ #category : #api }
GtGitLepiterDatabaseChangeImporter >> importOn: aParentNode [
	| databaseNode |
	databaseNode := self createDatabaseNodeOn: aParentNode.
	self importPageDefinitionsOn: databaseNode.
	self importLinksDefinitionOn: databaseNode.
	self importAttachmentDefinitionsOn: databaseNode
]

{ #category : #'definitions importing' }
GtGitLepiterDatabaseChangeImporter >> importPageDefinitionsOn: databaseNode [
	| pagesDefinition pagesNode |
	pagesDefinition := GtLepiterPagesDefinition new.
	pagesNode := databaseNode addChild: pagesDefinition.
	lepiterDatabaseChange pageChanges do: [ :aPageChange | 
		| fileReference pageDefinition page contents |
		fileReference := version resolveDelta: aPageChange delta.
		fileReference exists ifTrue: [ 
			contents := fileReference contents.
			page := contents readStreamDo: [ :aStream |
				LeJsonV4 uniqueInstance 
					deserialize: aStream ].
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
