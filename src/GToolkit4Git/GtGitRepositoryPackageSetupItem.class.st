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
		cr.
		aStream next
		appendingAdornment: [ self setupCustomPackageAction ];
		putAll: ' or '.
]

{ #category : #accessing }
GtGitRepositoryPackageSetupItem >> checkboxPredicate [
	^  self repository hasPackage
]

{ #category : #accessing }
GtGitRepositoryPackageSetupItem >> message [
	^ 'Add Package to Repository'
]

{ #category : #accessing }
GtGitRepositoryPackageSetupItem >> setupCustomPackageAction [
	^ GtSpotterDropdownButtonStencil new
		valuable: [ RPackage organizer packages ];
		icon: [ BlElement new
				size: 0 @ 0;
				background: BlBackground transparent ] asStencil;
		label: 'Add Existing Package';
		actOn: [ :anActOnEvent :anItem | 
			self repository icebergWorkingCopy addPackageNamed: anItem name asSymbol.
			self repository announceRepositoryModified.
			anActOnEvent beActed ]
]

{ #category : #accessing }
GtGitRepositoryPackageSetupItem >> setupPackageAction [
	^ self
		actionButtonLabelled: 'Create a package'
		withDropdownContent: [ :aButton | 
			GtGitPackageCreationForm new
				repositoryModel: self repository;
				button: aButton ]
]
