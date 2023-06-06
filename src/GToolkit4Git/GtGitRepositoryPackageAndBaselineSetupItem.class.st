Class {
	#name : #GtGitRepositoryPackageAndBaselineSetupItem,
	#superclass : #GtGitRepositorySetupItem,
	#category : #'GToolkit4Git-Model'
}

{ #category : #accessing }
GtGitRepositoryPackageAndBaselineSetupItem class >> priority [
	^ 2
]

{ #category : #accessing }
GtGitRepositoryPackageAndBaselineSetupItem >> buildActionsIn: aStream [
	aStream next
		appendingAdornment: [ self setupPackageAction ];
		cr
]

{ #category : #accessing }
GtGitRepositoryPackageAndBaselineSetupItem >> isExecuted [
	^  self repository hasPackage
]

{ #category : #accessing }
GtGitRepositoryPackageAndBaselineSetupItem >> message [
	^ 'Setup package and baseline for code management'
]

{ #category : #accessing }
GtGitRepositoryPackageAndBaselineSetupItem >> setupPackageAction [
	^ self
		actionButtonLabelled: 'Create a package and/or baseline'
		withDropdownContent: [ :aButton | 
			GtGitPackageAndBaselineCreationForm new
				repositoryModel: self repository;
				button: aButton ]
]
