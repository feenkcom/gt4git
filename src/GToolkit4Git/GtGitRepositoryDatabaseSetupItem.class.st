Class {
	#name : #GtGitRepositoryDatabaseSetupItem,
	#superclass : #GtGitRepositorySetupItem,
	#category : #'GToolkit4Git-Model'
}

{ #category : #accessing }
GtGitRepositoryDatabaseSetupItem class >> priority [
	^ 4
]

{ #category : #accessing }
GtGitRepositoryDatabaseSetupItem >> addToBaseline: aDatabaseFolder [
	| baseline |
	self repository hasBaseline ifFalse: [ ^ self ].
	baseline := self repository baselines first asClass.
	(RBAddMethodChange
		compile: 'loadLepiter
	IceRepository registry  
		detect: [ :aRepository |
			aRepository name = '''
				, self repository name
				, ''' ]
		ifFound: [ :aRepository | 
			| defaultDatabase currentProperties |
			defaultDatabase := LeDatabasesRegistry defaultLogicalDatabase.
			currentProperties := defaultDatabase properties.
			currentProperties addRegisteredDirectory: aRepository repositoryDirectory / '
				, aDatabaseFolder
				, '.
			defaultDatabase reload ]
		ifNone: [
			self inform: ''Repository not found.'' ]'
		in: baseline class
		classified: #loading) execute.

	self addToReadme
]

{ #category : #accessing }
GtGitRepositoryDatabaseSetupItem >> addToReadme [
	| readme |
	readme := self repository repository repositoryDirectory / 'README.md'.
	readme
		writeStreamDo: [ :s | 
			s setToEnd
				nextPutAll: '## Load Lepiter
				
After installing with Metacello, you will be able to execute

```
#' , self repository baselines first
						, ' asClass loadLepiter
```

' ].
	self repository repository addFileToIndex: 'README.md'.
	self repository announceRepositoryModified
]

{ #category : #accessing }
GtGitRepositoryDatabaseSetupItem >> buildActionsIn: aStream [
	aStream next
		appendingAdornment: [ self setupLepiterDatabaseAction ];
		cr
]

{ #category : #accessing }
GtGitRepositoryDatabaseSetupItem >> isExecuted [
	^ self repository hasDatabase
]

{ #category : #accessing }
GtGitRepositoryDatabaseSetupItem >> isRequired [
	^ false
]

{ #category : #accessing }
GtGitRepositoryDatabaseSetupItem >> message [
	^ 'Add Lepiter Knowledge Base'
]

{ #category : #accessing }
GtGitRepositoryDatabaseSetupItem >> setupLepiterDatabaseAction [
	^ self
		actionButtonLabelled: 'Create Lepiter directory'
		withDropdownContent: [ :aButton | 
			GtGitDatabaseCreationForm new
				repositoryModel: self repository;
				button: aButton ]
]
