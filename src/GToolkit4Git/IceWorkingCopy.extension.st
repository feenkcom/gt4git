Extension { #name : #IceWorkingCopy }

{ #category : #'*GToolkit4Git' }
IceWorkingCopy >> gtPackagesFor: aView [
	<gtView>
	^ aView columnedList 
		priority: 15;
		title: 'Packages' translated;
		items: [ (IceSortingStrategy new first: #modified) sort: self packages ];
		updateWhen: IceRepositoryModified in: Iceberg announcer;
		column: 'Name' item: #gtPackageDescription;
		column: 'Status' item: #gtPackageStatus
]

{ #category : #'*GToolkit4Git' }
IceWorkingCopy >> gtViewDiffToReferenceCommitFor: aView [
	<gtView>
	^ (self diffToReferenceCommit 
		gtViewInspectorDiffFor: aView)
			priority: 19
]
