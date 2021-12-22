Class {
	#name : #GtGitLepiterDatabaseChangeImporter,
	#superclass : #Object,
	#instVars : [
		'version',
		'lepiterDatabaseChange'
	],
	#category : #'BaselineOfGToolkit4Git-Changes'
}

{ #category : #accessing }
GtGitLepiterDatabaseChangeImporter >> createDatabaseNodeOn: aParentNode [
	| databaseDefinition |
	databaseDefinition := GtLepiterDatabaseDefinition new
		name: lepiterDatabaseChange database databaseName;
		databaseId: lepiterDatabaseChange database uuid;
		localRootRelativePath: (RelativePath with:
			lepiterDatabaseChange database localStoreRootDirectory basename).
	^ aParentNode addChild: databaseDefinition
]

{ #category : #accessing }
GtGitLepiterDatabaseChangeImporter >> importAttachmentDefinitionsOn: databaseNode [

	| attachmentsDefinition attachmentsNode |
	attachmentsDefinition := GtLepiterAttachmentsDefinition new.
	attachmentsNode := databaseNode addChild: attachmentsDefinition.
	lepiterDatabaseChange attachments do: [ :attachmentChange | 
		| fileReference attachmentDefinition contents attachmentNode |
		fileReference := version resolveDelta: attachmentChange delta.
		attachmentDefinition := GtLepiterAttachmentDefinition new name: fileReference parent basename.
		attachmentNode := attachmentsNode addChild: attachmentDefinition.
		fileReference exists ifTrue: [ 
			contents := fileReference gtBinaryContents.
			attachmentDefinition := GtLepiterAttachmentFileDefinition new
				                        name: fileReference basename;
				                        fileName: fileReference basename;
				                        binaryContents: contents.
			attachmentNode addChild: attachmentDefinition ] ]
]

{ #category : #accessing }
GtGitLepiterDatabaseChangeImporter >> importOn: aParentNode [

	| databaseSnapshot databaseNode |
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
			page := LeJsonV4 uniqueInstance deserialize:
				        fileReference readStream.
			pageDefinition := GtLepiterPageDefinition new
				                  name: page title;
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
