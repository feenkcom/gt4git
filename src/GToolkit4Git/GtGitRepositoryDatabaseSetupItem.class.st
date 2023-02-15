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
