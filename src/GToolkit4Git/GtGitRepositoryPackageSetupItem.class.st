Class {
	#name : #GtGitRepositoryPackageSetupItem,
	#superclass : #GtGitRepositorySetupItem,
	#category : #'GToolkit4Git-Model'
}

{ #category : #accessing }
GtGitRepositoryPackageSetupItem class >> priority [
	^ 2
]

{ #category : #accessing }
GtGitRepositoryPackageSetupItem >> buildActionsIn: aStream [
	aStream next
		appendingAdornment: [ self setupPackageAction ];
		cr
]

{ #category : #accessing }
GtGitRepositoryPackageSetupItem >> isExecuted [
	^  self repository hasPackage
]

{ #category : #accessing }
GtGitRepositoryPackageSetupItem >> message [
	^ 'Setup Packages and Baselines'
]

{ #category : #accessing }
GtGitRepositoryPackageSetupItem >> setupPackageAction [
	^ self
		actionButtonLabelled: 'Create a package and/or baseline'
		withDropdownContent: [ :aButton | 
			GtGitPackageCreationForm new
				repositoryModel: self repository;
				button: aButton ]
]
