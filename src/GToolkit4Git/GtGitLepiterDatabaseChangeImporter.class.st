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
		localRootRelativePath: (self 
			relativePathForDatabase: lepiterDatabaseChange database).
	
	databaseNode := aParentNode addChild: databaseDefinition.
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
GtGitLepiterDatabaseChangeImporter >> importAttachmentDefinitionsOn: aDatabaseNode [
	| attachmentsDefinition attachmentsNode |
	attachmentsDefinition := GtLepiterAttachmentsDefinition new.
	attachmentsNode := aDatabaseNode addChild: attachmentsDefinition.
	
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
	(fileReference isNil or: [ fileReference exists not ]) ifTrue: [ ^ self ].

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
	(fileReference isNil or: [ fileReference exists not ]) ifTrue: [ ^ self ].
	
	attachmentFileDefinition := GtLepiterAttachmentPropertiesDefinition new
		name: fileReference basename;
		fileName: fileReference basename;
		fileContents: fileReference contents.
	anAttachmentNode addChild: attachmentFileDefinition
]

{ #category : #'definitions importing' }
GtGitLepiterDatabaseChangeImporter >> importDatabasePropertiesDefinitionOn: databaseNode [
	| fileReference |

	lepiterDatabaseChange propertiesFileChange ifNil: [ ^ self ].
	fileReference := version resolveDelta: lepiterDatabaseChange propertiesFileChange delta.
	(fileReference isNil or: [ fileReference exists not ]) ifTrue: [ ^ self ].
	
	databaseNode addChild: (GtLepiterDatabasePropertiesDefinition new
		name: fileReference basename;
		fileName: fileReference basename;
		fileContents: fileReference contents)
]

{ #category : #'definitions importing' }
GtGitLepiterDatabaseChangeImporter >> importLinksDefinitionOn: aDatabaseNode [
	| fileReference linksDefinition |
	
	lepiterDatabaseChange linksChange ifNil: [ ^ self ].
	
	fileReference := version 
		resolveDelta: lepiterDatabaseChange linksChange delta.
	(fileReference isNil or: [ fileReference exists not ]) ifTrue: [ ^ self ].
	
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
	self importDatabasePropertiesDefinitionOn: databaseNode.
	self importPageDefinitionsOn: databaseNode.
	self importLinksDefinitionOn: databaseNode.
	self importAttachmentDefinitionsOn: databaseNode
]

{ #category : #'definitions importing' }
GtGitLepiterDatabaseChangeImporter >> importPageDefinitionFor: aPageChange on: aPagesNode in: aDatabaseNode [
	| fileReference pageDefinition page contents |
	fileReference := version resolveDelta: aPageChange delta.
	(fileReference isNil or: [ fileReference exists not ]) ifTrue: [ ^ self ].
	
	contents := fileReference contents.
	page := LeJsonV4 uniqueInstance 
		deserialize: contents readStream.
	pageDefinition := GtLepiterPageDefinition new
		name: page title;
		fileName: fileReference basename;
		database: aDatabaseNode value;
		pageUuid: page uid;
		pageContents: contents.
	aPagesNode addChild: pageDefinition 
]

{ #category : #'definitions importing' }
GtGitLepiterDatabaseChangeImporter >> importPageDefinitionsOn: aDatabaseNode [
	| pagesDefinition pagesNode |
	pagesDefinition := GtLepiterPagesDefinition new.
	pagesNode := aDatabaseNode addChild: pagesDefinition.
	lepiterDatabaseChange pageChanges do: [ :aPageChange | 
		self importPageDefinitionFor: aPageChange on: pagesNode in: aDatabaseNode ]
]

{ #category : #accessing }
GtGitLepiterDatabaseChangeImporter >> lepiterDatabaseChange: aLepiterDatabaseChange [
	lepiterDatabaseChange := aLepiterDatabaseChange
]

{ #category : #accessing }
GtGitLepiterDatabaseChangeImporter >> relativePathForDatabase: aDatabase [
	^ aDatabase localStoreRootDirectory asFileReference path 
			relativeTo: version repository repositoryDirectory
]

{ #category : #accessing }
GtGitLepiterDatabaseChangeImporter >> version: aVersion [
	version := aVersion
]
