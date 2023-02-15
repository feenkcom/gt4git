Class {
	#name : #GtGitRepositorySourceSetupItem,
	#superclass : #GtGitRepositorySetupItem,
	#category : #'GToolkit4Git-Model'
}

{ #category : #accessing }
GtGitRepositorySourceSetupItem class >> priority [
	^ 1
]

{ #category : #accessing }
GtGitRepositorySourceSetupItem >> buildActionsIn: aStream [
	aStream next
		appendingAdornment: [ self setupSourceDirectoryAction ];
		cr
]

{ #category : #accessing }
GtGitRepositorySourceSetupItem >> isExecuted [
	^ self repository repository project isUnborn not
]

{ #category : #accessing }
GtGitRepositorySourceSetupItem >> message [
	^ 'Setup metadata and source directory'
]

{ #category : #accessing }
GtGitRepositorySourceSetupItem >> setupSourceDirectoryAction [
	^ self
		actionButtonLabelled: 'Create a source directory'
		withDropdownContent: [ :aButton | 
			GtGitSourceDirectoryCreationForm new
				repositoryModel: self repository;
				button: aButton]
]
