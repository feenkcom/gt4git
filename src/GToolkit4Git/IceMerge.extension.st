Extension { #name : #IceMerge }

{ #category : #'*GToolkit4Git' }
IceMerge >> executeWithoutConflictSignal [
	[ self execute ]
		on: IceMergeResolutionRequest 
		do: [ :exception |
			self assert: self unresolvedConflictCount = 0. 
			exception resume: true ]
]

{ #category : #'*GToolkit4Git' }
IceMerge >> gtActionMergeFor: anAction [

	<gtAction>
	self isMerged ifFalse: [ ^ anAction ].

	^ anAction button
		  label: 'Merge';
		  action: [ :aButton | 
			  self updateHead.

			  self updateWorkingCopy.
			  
			  Iceberg announcer announce: (IceRepositoryModified for: self repository).
			  Iceberg announcer announce: (IceCommited for: self repository).
			
			  aButton phlow fireUpdateWish ]
]

{ #category : #'*GToolkit4Git' }
IceMerge >> gtConflicts [
	| conflicts |
	conflicts := OrderedCollection new.
	self conflictsDo: [ :anOperation | 
		conflicts add: anOperation ].
	
	^ conflicts
]

{ #category : #'*GToolkit4Git' }
IceMerge >> gtInspectorMergeWindowIn: composite [
	<gtInspectorPresentationOrder:20>
	composite morph 
		title: 'Merge';
		display: [    
			|mergeMorph|
			 mergeMorph := (IceTipMergeMorph forMerger: self).
		    mergeMorph
		        fromDescription: self sourceDescription;
		        toDescription: self targetDescription.
			 mergeMorph ]
]

{ #category : #'*GToolkit4Git' }
IceMerge >> gtViewInspectorDiffFor: aView [

	<gtView>
	^ aView tree
		  title: 'Changes';
		  items: [ self treeToShow children ];
		  children: #children;
		  expandAll;
		  updateWhen: GtIceMergeConflictResolved in: [ Iceberg announcer ];
		  stencil: [ :anIceNode | 
			  | element |
			  element := BlElement new
				             layout: BlLinearLayout horizontal;
				             constraintsDo: [ :c | 
					             c horizontal matchParent.
					             c vertical fitContent ];
				             margin: (BlInsets all: 3);
				             constraintsDo: [ :c | c vertical fitContent ];
				             "aptitude:
					(BrGlamorousWithContextMenuAptitude
						content: [ BrGlamorousSimpleContextMenuContent new
								display:
									{('Revert changes' -> [ self revertChanges: anIceNode ])};
								yourself ]);"
				             addChild:
					             (anIceNode value icon asElement constraintsDo: [ :c | 
							              c linear vertical alignCenter ]);
				             addChild: (BrLabel new
						              text: anIceNode key asString;
						              aptitude: BrGlamorousLabelAptitude;
						              padding: (BlInsets
								               top: 3
								               left: 6
								               bottom: 0
								               right: 3);
						              constraintsDo: [ :c | 
							              c linear horizontal alignCenter ]).
			  Iceberg announcer
				  when: GtIceMergeConflictResolved
				  do: [ element phlow fireUpdateWish ].

			  anIceNode value isUnresolvedConflict ifTrue: [ 
				  element addChild:
					  (BrGlamorousVectorIcons debug asElement constraintsDo: [ :c | 
						   c linear vertical alignCenter ]) ].
			  element ]
]
