Class {
	#name : #GtGitLepiterChangesFromDeltasBuilder,
	#superclass : #Object,
	#instVars : [
		'icebergRepository',
		'databases'
	],
	#category : #'GToolkit4Git-Lepiter'
}

{ #category : #api }
GtGitLepiterChangesFromDeltasBuilder >> changesForDeltasByDatabase: deltasByDatabase [
	^ deltasByDatabase associations collect: [ :anAssociation |
			| databaseChange |
			databaseChange := GtLepiterLocalDatabaseChange new 
				database: anAssociation key.
			self 
				importChangesFromDeltas: anAssociation value
				intoDatabaseChange: databaseChange.
			databaseChange ]
]

{ #category : #api }
GtGitLepiterChangesFromDeltasBuilder >> changesFromDeltas: aDeltasCollection [
	| deltasByDatabase normalFileDeltas |
	
	"First analyse the deltas and group the deltas for specific databases,
	and deltas for normal files"
	deltasByDatabase := OrderedDictionary new.
	normalFileDeltas := OrderedCollection new.
	
	aDeltasCollection do: [ :aDelta |
		| targetGroup |
		targetGroup := self databases 
			detect: [ :aDatabase | 
				| filePath |
				filePath := RelativePath with: aDelta newFileRelative.
				(self relativePathForDatabase: aDatabase) contains: filePath ] 
			ifFound: [ :aDatabase |
				deltasByDatabase 
					at: aDatabase
					ifAbsentPut: [ OrderedCollection new ] ]
			ifNone: [ normalFileDeltas ].
		targetGroup add: aDelta ].
	
	^ self changesForDeltasByDatabase: deltasByDatabase
	"self changesForFileDeltas: normalFileDeltas"
		
	
]

{ #category : #accessing }
GtGitLepiterChangesFromDeltasBuilder >> databases [

	^ databases
]

{ #category : #accessing }
GtGitLepiterChangesFromDeltasBuilder >> databases: anObject [

	databases := anObject
]

{ #category : #accessing }
GtGitLepiterChangesFromDeltasBuilder >> icebergRepository [

	^ icebergRepository
]

{ #category : #accessing }
GtGitLepiterChangesFromDeltasBuilder >> icebergRepository: anObject [

	icebergRepository := anObject
]

{ #category : #'changes importing' }
GtGitLepiterChangesFromDeltasBuilder >> importAttachmentDelta: aDelta intoDatabaseChange: aDatabaseChange [ 
	| attachmentPath uuidString attachmentChange |
	attachmentPath := RelativePath with: aDelta newFileRelative.
	uuidString := attachmentPath parent basename.
	attachmentChange := aDatabaseChange attachmentChanges
		detect: [ :anAttachmentChange | 
			anAttachmentChange uuidString = uuidString ]
		ifNone: [ 
			| newAttachmentChange |
			newAttachmentChange := GtLepiterLocalAttachmentChange new 
				uuidString: uuidString.
			aDatabaseChange addAttachmentChange: newAttachmentChange.
			newAttachmentChange path: attachmentPath parent.
			newAttachmentChange ].
	
	attachmentPath basename = LeAttachment basename ifTrue: [
		^ attachmentChange propertiesChange:  (GtLepiterLocalAttachmentPropertiesFileChange new 
			path: attachmentPath; 
			delta: aDelta) ].
	
	attachmentChange addFileChange: (GtLepiterLocalAttachmentFileChange new 
		path: attachmentPath; 
		delta: aDelta)
]

{ #category : #'changes importing' }
GtGitLepiterChangesFromDeltasBuilder >> importChangesFromDelta: aDelta intoDatabaseChange: aDatabaseChange [
	(self isPageDelta: aDelta forDatabase: aDatabaseChange database) ifTrue: [
		^ self importPageDelta: aDelta intoDatabaseChange: aDatabaseChange ].
	
	(self isAttachmentDelta: aDelta forDatabase: aDatabaseChange database) ifTrue: [
		^ self importAttachmentDelta: aDelta intoDatabaseChange: aDatabaseChange ].
	(self isDatabasePropertiesDelta: aDelta forDatabase: aDatabaseChange database) ifTrue: [
		^ self 
			importDatabasePropertiesDelta: aDelta 
			intoDatabaseChange: aDatabaseChange ].
	(self isLinksDelta: aDelta forDatabase: aDatabaseChange database) ifTrue: [
		^ self 
			importLinksDelta: aDelta 
			intoDatabaseChange: aDatabaseChange ].
	
	"Error signal: 'Unknown Delta'."
]

{ #category : #'changes importing' }
GtGitLepiterChangesFromDeltasBuilder >> importChangesFromDeltas: aCollectionOfDeltas intoDatabaseChange: aDatabaseChange [
	aCollectionOfDeltas do: [ :aDelta |
		self 
			importChangesFromDelta: aDelta 
			intoDatabaseChange: aDatabaseChange ]
]

{ #category : #'changes importing' }
GtGitLepiterChangesFromDeltasBuilder >> importDatabasePropertiesDelta: aDelta intoDatabaseChange: aDatabaseChange [ 
	aDatabaseChange propertiesFileChange: (GtLepiterLocalDatabasePropertiesFileChange new 
		path: (RelativePath with: aDelta newFileRelative); 
		delta: aDelta)
]

{ #category : #'changes importing' }
GtGitLepiterChangesFromDeltasBuilder >> importLinksDelta: aDelta intoDatabaseChange: aDatabaseChange [ 
	aDatabaseChange linksChange: (GtLepiterLocalLinksChange new 
		path: (RelativePath with: aDelta newFileRelative); 
		delta: aDelta)
]

{ #category : #'changes importing' }
GtGitLepiterChangesFromDeltasBuilder >> importPageDelta: aDelta intoDatabaseChange: aDatabaseChange [ 
	aDatabaseChange addPageChange: (GtLepiterLocalPageChange new 
		path: (RelativePath with: aDelta newFileRelative); 
		delta: aDelta)
]

{ #category : #testing }
GtGitLepiterChangesFromDeltasBuilder >> isAttachmentDelta: aDelta forDatabase: aDatabase [
	| attachmentPath |
	
	attachmentPath := RelativePath with: aDelta newFileRelative.
	^  ((self relativePathForDatabase: aDatabase) / 'attachments') contains: attachmentPath 
]

{ #category : #testing }
GtGitLepiterChangesFromDeltasBuilder >> isDatabasePropertiesDelta: aDelta forDatabase:  aDatabase [
	| filePath |
	
	filePath := RelativePath with: aDelta newFileRelative.
	^ (filePath parent = (self relativePathForDatabase: aDatabase))
			and: [ filePath basename = LepiterCoreDefaults databasePropertiesBasename ]
]

{ #category : #testing }
GtGitLepiterChangesFromDeltasBuilder >> isLinksDelta: aDelta forDatabase: aDatabase [
	| filePath |
	
	filePath := RelativePath with: aDelta newFileRelative.
	^ (filePath parent = (self relativePathForDatabase: aDatabase))
			and: [ filePath basename endsWith: '.lepiter.links' ]
]

{ #category : #testing }
GtGitLepiterChangesFromDeltasBuilder >> isPageDelta: aDelta forDatabase: aDatabase [
	| pagePath |
	
	pagePath := RelativePath with: aDelta newFileRelative.
	^ (pagePath parent = (self relativePathForDatabase: aDatabase))
			and: [ pagePath basename endsWith: '.lepiter' ]
]

{ #category : #accessing }
GtGitLepiterChangesFromDeltasBuilder >> relativePathForDatabase: aDatabase [
	^ aDatabase localStoreRootDirectory asFileReference path 
			relativeTo: icebergRepository repositoryDirectory
]
