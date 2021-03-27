Class {
	#name : #GtGitRepositoryChangesElement,
	#superclass : #BlElement,
	#traits : 'TGtGitWithRepositoryViewModel + TBrLayoutResizable',
	#classTraits : 'TGtGitWithRepositoryViewModel classTrait + TBrLayoutResizable classTrait',
	#instVars : [
		'treeElement'
	],
	#category : #'GToolkit4Git-UI - Element'
}

{ #category : #initialization }
GtGitRepositoryChangesElement >> defaultLayout [
	^ BlLinearLayout vertical
]

{ #category : #initialization }
GtGitRepositoryChangesElement >> initialize [
	super initialize.
	self initializeTreeElement.
	
	self addChild: self treeElement as: #changes.
	
	self matchParent.
]

{ #category : #initialization }
GtGitRepositoryChangesElement >> initializeTreeElement [
	treeElement := BrSimpleTree new
		rowStencil: (BrGlamorousSimpleTreeSelectableRowElementStencilBuilder new);
		matchParent.
	
	treeElement 
		nodeStencil: [ 
			BrHorizontalPane new
				margin: (BlInsets all: 3);
				alignCenterLeft;
				hMatchParent;
				vFitContent;
				addChild: (BlElement new
					id: #icon;
					size: 16@16);
				addChild: (BrLabel new
					id: #label;
					aptitude: BrGlamorousLabelAptitude;
					margin: (BlInsets left: 6);
					constraintsDo: [ :c | 
						c linear horizontal alignCenter ]) ];
		nodeDataBinder: [ :aNodeElement :anIceNode :aTreeNode |
			| anIcon |
			anIcon := anIceNode value icon.
			(aNodeElement childNamed: #icon)
				background: anIcon;
				size: anIcon extent.
			(aNodeElement childNamed: #label)
				text: anIceNode key asString asRopedText ].
			
	treeElement when: BrSelectionChanged do: [ :anEvent | self onCodeChangeSelectionChanged: anEvent ].
]

{ #category : #'private - event handling' }
GtGitRepositoryChangesElement >> onCodeChangeSelectionChanged: anEvent [
	anEvent currentTarget selectedNodeDo: [ :aNode |
		anEvent currentTarget phlow spawnObject: aNode value ]
]

{ #category : #'api - repository view model' }
GtGitRepositoryChangesElement >> onRepositoryViewModelChanged [
	"Is sent when a new repository view model is assigned to the element.
	Note: #onRepositoryViewModelChanged is sent before #subscribeToRepositoryViewModel
	which means that if you perform any operation that triggers an announcement it will be ignored because the receiver
	didn't get a chance to subscribe to any announcement. Override #onPostRepositoryViewModelChanged if you
	wish to perform an operation that requires an announcement, but keep in mind that this is not the most efficient way"

	self updateElement.
]

{ #category : #'private - accessing' }
GtGitRepositoryChangesElement >> treeElement [
	^ treeElement
]

{ #category : #'private - updating' }
GtGitRepositoryChangesElement >> updateElement [
	| aTree |
	aTree := self repositoryViewModel repositoryModel changes.
	self treeElement items: aTree immediate: #children.
	self treeElement expandUpTo: 3.
]
