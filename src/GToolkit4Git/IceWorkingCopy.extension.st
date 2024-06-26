Extension { #name : #IceWorkingCopy }

{ #category : #'*GToolkit4Git' }
IceWorkingCopy >> gtAllLoadedExamples [
	^ self loadedPackages flatCollect: [ :anIcePackage |
		| rPackage |
		rPackage := RPackage organizer
			packageNamed: anIcePackage name
			ifAbsent: [ nil ].
		rPackage 
			ifNil: [ #() ]
			ifNotNil: [ rPackage gtExamplesAllContained ] ]
]

{ #category : #'*GToolkit4Git' }
IceWorkingCopy >> gtPackagesFor: aView [
	<gtView>
	^ aView columnedList
		priority: 15;
		title: 'Packages' translated;
		items: [ (IceSortingStrategy new first: #modified) sort: self packages ];
		contextItemLabel: 'Remove'
			action: [ :element :item | 
				item remove.
				Iceberg announcer
					announce: (IceRepositoryModified new repository: self repository).
				element phlow fireToolUpdateWish ];
		contextItemLabel: 'Reload (Force)'
			action: [ :element :item | [ item reload ] on: MCMergeOrLoadWarning do: [ :err | err load ] ];
		contextItemLabel: 'Reload (Merge)'
			action: [ :element :item | [ item reload ] on: MCMergeOrLoadWarning do: [ :err | err merge ] ];
		contextItemLabel: 'Reload (Bail)'
			action: [ :element :item | [ item reload ] on: MCMergeOrLoadWarning do: [ :err | err cancel ] ];
		updateWhen: IceRepositoryModified in: Iceberg announcer;
		actionUpdateButton;
		column: 'Name' text: #gtPackageDescription;
		column: 'Status'
			icon: #gtPackageStatus
			width: 100;
		sendTool: [ :aPackage | 
			aPackage isLoaded
				ifTrue: [ GtPackageCoderTool package: aPackage name asPackage ]
				ifFalse: [ GtInspectorTool forObject: aPackage ] ];
		actionStencil: [ :anElement | 
				GtSpotterDropdownButtonStencil new
					valuable: [ RPackage organizer packages ];
					tooltip: 'Add Package';
					icon: BrGlamorousVectorIcons add;
					objectActOn: [ :anActOnEvent :anItem | 
						self addPackageNamed: anItem name.
						Iceberg announcer
							announce: (IceRepositoryModified new repository: self repository).
						anElement phlow fireToolUpdateWish.
						anActOnEvent beActed ] ]
			tooltip: 'Add Package'
]

{ #category : #'*GToolkit4Git' }
IceWorkingCopy >> gtViewDiffToReferenceCommitFor: aView [
	<gtView>
	^ (self diffToReferenceCommit 
		gtViewInspectorDiffFor: aView)
			priority: 19
]

{ #category : #'*GToolkit4Git' }
IceWorkingCopy >> notifyPackageModified: aString [
	<gtPharoPatch: #Pharo>
	
	self flag: #pharoTodo. "we cannot use #includesPackageNamed: as is because it can happen 
	that a package is present in a commit but not in image yet?"

	self shouldIgnoreNotifications ifTrue: [ ^ false ].

	(self includesInWorkingCopyPackageNamed: aString) ifTrue: [ 
		| package |
		package := self packageNamed: aString.
		package isDirty ifFalse: [ package beDirty ].
		^ true ].
	^ false
]

{ #category : #'*GToolkit4Git' }
IceWorkingCopy >> removePackageNamed: aPackageName [
	^ (RPackage organizer
			packageNamed: aPackageName
			ifAbsent: [ ^ self ]) removeFromSystem
]
