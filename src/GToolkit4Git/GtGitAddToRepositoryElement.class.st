Class {
	#name : #GtGitAddToRepositoryElement,
	#superclass : #BlElement,
	#traits : 'TBrLayoutResizable',
	#classTraits : 'TBrLayoutResizable classTrait',
	#instVars : [
		'package'
	],
	#category : #'GToolkit4Git-UI'
}

{ #category : #accessing }
GtGitAddToRepositoryElement >> asElementDo: aBlock [
	^ aBlock value: self
]

{ #category : #accessing }
GtGitAddToRepositoryElement >> initialize [

	super initialize.
	self matchParent.
	self margin: (BlInsets all: 5).
	self layout: BlLinearLayout vertical.
	
	self setupListeners
]

{ #category : #accessing }
GtGitAddToRepositoryElement >> onAnnouncement: anAnnouncement [
	package ifNotNil: [ self onPackageAdded ]
]

{ #category : #accessing }
GtGitAddToRepositoryElement >> onPackageAdded [
	self removeChildren.

	self
		addChild: (BrToolbar new hMatchParent
				height: 30;
				addChild: (BrLabel new
						aptitude: BrGlamorousLabelAptitude new bold;
						beHugeSize;
						hMatchParent;
						vFitContent;
						text: 'Select repository for package ' , self package name));
		addChild: (BrSimpleList new
				items: (IceRepository registry
						copyFrom: 1 to: IceRepository registry size;
						select: [ :aRepository | aRepository workingCopy isNotNil ]);
				itemStencil: [ BrLabel new hMatchParent
						aptitude: BrGlamorousLabelAptitude + BrGlamorousListItemAptitude ];
				itemDataBinder: [ :aLabel :aRepository | 
					aLabel
						text: aRepository name;
						when: BlClickEvent
							do: [ :_ | 
								aRepository workingCopy addPackageNamed: self package name.
								self phlow
									spawnTool: (GtGitPhlowTool new
											repository: (GtGitRepository fromIcebergRepository: aRepository)) ] ])
]

{ #category : #accessing }
GtGitAddToRepositoryElement >> package [
	^ package
]

{ #category : #accessing }
GtGitAddToRepositoryElement >> package: aPackage [
	package := aPackage.
	
	self onPackageAdded
]

{ #category : #accessing }
GtGitAddToRepositoryElement >> setupListeners [
	Iceberg announcer weak
		when: IceRepositoryRegistryAnnouncement
		send: #onAnnouncement:
		to: self
]
