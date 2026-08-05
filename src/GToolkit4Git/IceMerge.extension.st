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
			  self executeWithoutConflictSignal.
			  
			  Iceberg announcer announce: (IceRepositoryModified for: self repository).
			  Iceberg announcer announce: (IceCommited for: self repository).
			
			  aButton phlow fireToolUpdateWish ]
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
