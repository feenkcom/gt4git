Class {
	#name : #GtGitRepositoryBaselineSetupItem,
	#superclass : #GtGitRepositorySetupItem,
	#category : #'GToolkit4Git-Model'
}

{ #category : #accessing }
GtGitRepositoryBaselineSetupItem class >> priority [
	^ 3
]

{ #category : #accessing }
GtGitRepositoryBaselineSetupItem >> buildActionsIn: aStream [
	aStream next
		appendingAdornment: [ self setupBaselineAction ];
		cr.
	aStream next
		appendingAdornment: [ self setupCustomBaselineAction ];
		putAll: ' or '
]

{ #category : #accessing }
GtGitRepositoryBaselineSetupItem >> checkboxPredicate [
	^ self repository hasBaseline
]

{ #category : #accessing }
GtGitRepositoryBaselineSetupItem >> message [
	^ 'Add Baseline to Repository'
]

{ #category : #accessing }
GtGitRepositoryBaselineSetupItem >> setupBaselineAction [
	^ self
		actionButtonLabelled: 'Create a baseline'
		withDropdownContent: [ :aButton | 
			GtGitBaselineCreationForm new
				repositoryModel: self;
				button: aButton ]
]

{ #category : #accessing }
GtGitRepositoryBaselineSetupItem >> setupCustomBaselineAction [
	^ GtSpotterDropdownButtonStencil new
		valuable: [ RPackage organizer packages
				select: [ :aPackage | aPackage name beginsWith: 'BaselineOf' ] ];
		icon: [ BlElement new
				size: 0 @ 0;
				background: BlBackground transparent ] asStencil;
		label: 'Add Existing Baseline';
		actOn: [ :anActOnEvent :anItem | 
			self repository icebergWorkingCopy addPackageNamed: anItem name asSymbol.
			Iceberg announcer
				announce: (IceRepositoryModified new repository: self repository repository).
			anActOnEvent beActed ]
]
