Extension { #name : #IceWorkingCopy }

{ #category : #'*GToolkit4Git' }
IceWorkingCopy >> gtPackagesFor: aView [
	<gtView>
	^ aView columnedList 
		priority: 15;
		title: 'Packages' translated;
		items: [ (IceSortingStrategy new first: #modified) sort: self packages ];
		updateWhen: IceRepositoryModified in: Iceberg announcer;
		column: 'Name' text: #gtPackageDescription;
		column: 'Status' icon: #gtPackageStatus width:100;
		sendTool: [ :aPackage | 
			aPackage isLoaded
				ifTrue: [ GtPackageCoderTool package: (aPackage name asPackage) ]
				ifFalse: [ GtInspectorTool forObject: aPackage ] ];
		actionStencil: [ :anElement | GtSpotterDropdownButtonStencil new
			object:RPackage organizer packages ;
			tooltip: 'Add Package';
			icon:BrGlamorousVectorIcons add;
			actOn: [ :anActOnEvent :anItem | 
				self addPackageNamed: anItem name.
				Iceberg announcer announce: 
					(IceRepositoryModified new repository: self repository).
				anElement phlow fireUpdateWish.
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
